// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts
import SwiftData

// MARK: - PZProfileSwiftData

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
enum PZProfileSwiftData {
    /// 为了消除 availability tag 与 ModelActor Macro 的兼容性问题，只能单独用一个 Enum 包着。
    @ModelActor
    actor PZProfileActor: PZProfileActorProtocol {
        public init(unitTests: Bool = false) {
            var isReset = false
            if unitTests {
                modelContainer = PZProfileActor.makeContainer4UnitTests()
            } else {
                let newContainer = PZProfileActor.makeContainer()
                modelContainer = newContainer.container
                isReset = newContainer.isReset
            }
            modelExecutor = DefaultSerialModelExecutor(
                modelContext: .init(modelContainer)
            )
            Task { @MainActor in
                let stillNeedsReset = await detectWhetherIsReset()
                isReset = isReset || stillNeedsReset
                // 处理资料库被重设的情形。
                if isReset {
                    await failSafeRestoreAllDataFromUserDefaults()
                }
                await arbitrateProfilesAgainstUserDefaults()
                await syncAllDataToUserDefaults()
            }
        }
    }
}

// MARK: - PZProfileActor

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
typealias PZProfileActor = PZProfileSwiftData.PZProfileActor

// MARK: - PZProfileActor.

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    @MainActor public static var shared: PZProfileActor? {
        singleton
    }

    public static let singleton: PZProfileActor? = {
        guard !Pizza.isNotMainApp else { return nil }
        return PZProfileActor()
    }()

    public static var modelConfig: ModelConfiguration {
        if Pizza.isAppStoreRelease {
            let useGroupContainer = Defaults[.situatePZProfileDBIntoGroupContainer]
            return ModelConfiguration(
                "PZProfileMODB",
                schema: Schema([PZProfileMO.self]),
                isStoredInMemoryOnly: false,
                groupContainer: useGroupContainer ? .identifier(appGroupID) : .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        } else {
            return ModelConfiguration(
                schema: Schema([PZProfileMO.self]),
                isStoredInMemoryOnly: false,
                groupContainer: .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        }
    }

    public static func makeContainer() -> (container: ModelContainer, isReset: Bool) {
        let config = Self.modelConfig
        do {
            return (try ModelContainer(for: Schema([PZProfileMO.self]), configurations: [config]), false)
        } catch {
            PZLog.error("[PZProfileActor] Initial ModelContainer creation failed: \(error)")
            // 尝试删除损坏的数据库文件及其关联的 WAL/SHM 文件后重建。
            let dbURL = config.url
            // 实际上是 .sqlite-wal，但 config.url 已是完整路径。
            let walURL = dbURL.appendingPathExtension("wal")
            let shmURL = dbURL.appendingPathExtension("shm")
            // 针对 SQLite 文件的后缀格式进行额外处理。
            let dbPath = dbURL.path
            let walURL2 = URL(fileURLWithPath: dbPath + "-wal")
            let shmURL2 = URL(fileURLWithPath: dbPath + "-shm")
            for fileURL in [dbURL, walURL, shmURL, walURL2, shmURL2] {
                try? FileManager.default.removeItem(at: fileURL)
            }
            Defaults[.lastTimeResetLocalProfileDB] = .now
            do {
                return (try ModelContainer(for: Schema([PZProfileMO.self]), configurations: [config]), true)
            } catch {
                PZLog.error("[PZProfileActor] Second ModelContainer creation also failed: \(error)")
            }
            // 兜底失败。
            preconditionFailure(
                "[PZProfileActor] Falling back to in-memory ModelContainer."
            )
        }
    }

    public static func makeContainer4UnitTests() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZProfileMO.self,
                configurations: ModelConfiguration(
                    "PZProfileMO",
                    schema: Schema([PZProfileMO.self]),
                    isStoredInMemoryOnly: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
            )
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
    }
}

// MARK: - AccountMO Related.

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    public func acceptMigratedOldAccountProfiles(
        oldData: [PZProfileSendable],
        resetNotifications: Bool = true,
        isUnattended: Bool = false
    ) async throws {
        let allExistingPFs = getSendableProfiles()
        let allExistingUUIDs: [String] = allExistingPFs.map(\.uuid.uuidString)
        var currentPriorityID = (allExistingPFs.map(\.priority).max() ?? 0) + 1
        var profilesMigratedCount = 0
        let nowTimestamp = Int64(Date().timeIntervalSince1970)
        try modelContext.transaction {
            oldData.forEach { theEntrySendable in
                let theEntry = theEntrySendable.asMO
                theEntry.priority = currentPriorityID
                theEntry.lastLocalEditTimestamp = nowTimestamp
                if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                    guard !isUnattended else { return }
                    theEntry.uuid = .init()
                    theEntry.name += " (Imported)"
                }
                modelContext.insert(theEntry)
                recordLocalEditTimestamp(nowTimestamp, uuidString: theEntry.uuid.uuidString)
                PZNotificationCenter.bleachNotificationsIfDisabled(for: theEntry.asSendable)
                profilesMigratedCount += 1
                currentPriorityID += 1
            }
        }
        syncAllDataToUserDefaults()
        if resetNotifications, profilesMigratedCount > 0 {
            await Broadcaster.shared.requireOSNotificationCenterAuthorization()
            await Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
        }
    }

    public func getSendableProfiles() -> [PZProfileSendable] {
        var result = (try? modelContext.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        result.fixPrioritySettings(respectExistingPriority: true)
        return result.sorted { $0.priority < $1.priority }
    }

    private func addOrUpdateProfileSansCommission(
        _ profileSendable: PZProfileSendable,
        against context: ModelContext
    ) throws {
        let existingObjs = try context.fetch(FetchDescriptor<PZProfileMO>())
        var matchedExistingObjs: [PZProfileMO] = existingObjs.filter {
            $0.uuid.uuidString == profileSendable.uuid.uuidString
        }
        let nowTimestamp = Int64(Date().timeIntervalSince1970)
        var existingDataUpdatedSuccessfully = false
        deduplicateAndUpdate: while let lastObj = matchedExistingObjs.last {
            if matchedExistingObjs.count > 1 {
                context.delete(lastObj)
                matchedExistingObjs.removeLast()
            } else {
                lastObj.inherit(from: profileSendable)
                lastObj.lastLocalEditTimestamp = nowTimestamp
                existingDataUpdatedSuccessfully = true
                break deduplicateAndUpdate
            }
        }
        if !existingDataUpdatedSuccessfully {
            let newMO = profileSendable.asMO
            newMO.lastLocalEditTimestamp = nowTimestamp
            context.insert(newMO)
        }
        recordLocalEditTimestamp(nowTimestamp, uuidString: profileSendable.uuid.uuidString)
    }

    /// This will add the profile if it is not already added.
    public func addOrUpdateProfile(_ profileSendable: PZProfileSendable) throws {
        try modelContext.transaction {
            try addOrUpdateProfileSansCommission(profileSendable, against: modelContext)
        }
    }

    public func addOrUpdateProfilesWithDeletion(
        _ profileSendableSet: Set<PZProfileSendable>,
        uuidsToDelete: Set<UUID>
    ) throws {
        try modelContext.transaction {
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard uuidsToDelete.contains(currentMO.uuid) else { return }
                modelContext.delete(currentMO)
            }
            try profileSendableSet.sorted {
                $0.priority < $1.priority
            }.forEach {
                try addOrUpdateProfileSansCommission($0, against: modelContext)
            }
        }
        // 仅清理「被删除且未被重新插入」的 uuid 的时间戳记录。
        let reinsertedUUIDs = Set(profileSendableSet.map(\.uuid))
        let pureDeletions = uuidsToDelete.subtracting(reinsertedUUIDs)
        removeLocalEditTimestamps(uuidStrings: pureDeletions.map(\.uuidString))
    }

    public func deleteProfile(uuid: UUID) throws {
        _ = try deleteProfiles(uuids: [uuid])
    }

    /// - Returns: Remaining entries.
    @discardableResult
    public func deleteProfiles(uuids: Set<UUID>) throws -> Set<PZProfileSendable> {
        var remainingProfiles = Set<PZProfileSendable>()
        try modelContext.transaction {
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard uuids.contains(currentMO.uuid) else {
                    remainingProfiles.insert(currentMO.asSendable)
                    return
                }
                modelContext.delete(currentMO)
            }
        }
        removeLocalEditTimestamps(uuidStrings: uuids.map(\.uuidString))
        return remainingProfiles
    }

    @discardableResult
    public func bleachInvalidProfiles() throws -> Set<PZProfileSendable> {
        var deletedProfiles = Set<PZProfileSendable>()
        PZLog.debug("[PZProfileActor] bleachInvalidProfiles: entering transaction...")
        try modelContext.transaction {
            PZLog.debug("[PZProfileActor] bleachInvalidProfiles: inside transaction, enumerating...")
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard currentMO.isInvalid else { return }
                modelContext.delete(currentMO)
                deletedProfiles.insert(currentMO.asSendable)
            }
            let countAfterEnum = deletedProfiles.count
            PZLog.debug(
                "[PZProfileActor] bleachInvalidProfiles: enumeration done, deleted=\(countAfterEnum)"
            )
        }
        PZLog.debug(
            "[PZProfileActor] bleachInvalidProfiles: transaction done, total deleted=\(deletedProfiles.count)"
        )
        removeLocalEditTimestamps(uuidStrings: deletedProfiles.map(\.uuid.uuidString))
        return deletedProfiles
    }
}

// MARK: - Backup and Restore

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    private func detectWhetherIsReset() -> Bool {
        let existingSQLCount = (try? modelContext.fetchCount(FetchDescriptor<PZProfileMO>())) ?? -1
        let isSQLEmpty = (existingSQLCount == 0)
        return isSQLEmpty && !Defaults[.pzProfiles].isEmpty
    }

    private func failSafeRestoreAllDataFromUserDefaults() {
        do {
            let existingCount = try modelContext.fetchCount(FetchDescriptor<PZProfileMO>())
            let backupProfiles = Defaults[.pzProfiles].values.sorted { $0.priority < $1.priority }
            guard existingCount == 0, !backupProfiles.isEmpty else { return }
            backupProfiles.map(\.asMO).forEach(modelContext.insert)
            try modelContext.save()
        } catch {
            PZLog.error("\(error)")
        }
    }
}

// MARK: - Deduplication.

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    /// Warning: 该方法仅对 SwiftData 资料库有操作，不影响 UserDefaults。
    @discardableResult
    public func deduplicate() throws
        -> (removed: Set<PZProfileSendable>, left: Set<PZProfileSendable>) {
        var existingMOs = (try modelContext.fetch(FetchDescriptor<PZProfileMO>()))
        existingMOs.sort { $0.priority < $1.priority }
        let existingProfiles = existingMOs.map(\.asSendable)
        var profileSet = Set<PZProfileSendable>(existingProfiles)
        let uniqueProfiles = profileSet
        /// 用这一行来判断是否有重复内容。没有的话就直接放弃处理。
        guard Set(existingProfiles) != Set(uniqueProfiles) else {
            return (removed: .init(), left: profileSet)
        }
        profileSet.removeAll()
        var profilesRemoved: Set<PZProfileSendable> = .init()
        try modelContext.transaction {
            existingMOs.forEach { currentMO in
                let sendableProfile = currentMO.asSendable
                if !profileSet.contains(sendableProfile) {
                    profileSet.insert(sendableProfile)
                } else {
                    modelContext.delete(currentMO)
                    profilesRemoved.insert(sendableProfile)
                }
            }
        }
        return (profilesRemoved, profileSet)
    }
}

// MARK: - DeviceFP Propagation.

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    /// This only works with Miyoushe UIDs.
    public func propagateDeviceFingerprint(_ fingerprint: String) throws {
        guard !fingerprint.isEmpty else { return }
        let existingMOs = (try modelContext.fetch(FetchDescriptor<PZProfileMO>()))
        let nowTimestamp = Int64(Date().timeIntervalSince1970)
        var stampedUUIDs: [String] = []
        try modelContext.transaction {
            existingMOs.forEach { currentMO in
                switch currentMO.server.region {
                case .hoyoLab: return
                case .miyoushe:
                    currentMO.deviceFingerPrint = fingerprint
                    currentMO.lastLocalEditTimestamp = nowTimestamp
                    stampedUUIDs.append(currentMO.uuid.uuidString)
                }
            }
        }
        stampedUUIDs.forEach { recordLocalEditTimestamp(nowTimestamp, uuidString: $0) }
    }
}

// MARK: - Local Edit Timestamp & Stale Data Arbitration.

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    /// 以 UserDefaults 内的副本与各资料最近接受本地修改的时间戳为据，
    /// 裁决并丢弃过期的资料变动（例如 CloudKit 导入造成的回滚）。
    ///
    /// - 本地库里的时间戳较旧：判定为过期资料，以 UserDefaults 副本写回。
    /// - 本地库里的时间戳较新：判定为他端装置的合法修改，予以接受并让影子表跟进。
    public func arbitrateProfilesAgainstUserDefaults() async {
        let shadowMap = Defaults[.pzProfilesLastLocalEditTimestamps]
        guard !shadowMap.isEmpty else { return }
        let backupMap = Defaults[.pzProfiles]
        guard let existingMOs = try? modelContext.fetch(FetchDescriptor<PZProfileMO>()) else { return }
        var shadowUpdates: [String: Int64] = [:]
        var needsSave = false
        for currentMO in existingMOs {
            let uuidStr = currentMO.uuid.uuidString
            let localTS = shadowMap[uuidStr] ?? 0
            let moTS = currentMO.lastLocalEditTimestamp ?? 0
            if moTS < localTS {
                // 本地库里的资料已过期（可能被 CloudKit 回滚）：以 UserDefaults 副本写回。
                guard let backup = backupMap[uuidStr] else { continue }
                currentMO.inherit(from: backup)
                let newTS = max(localTS, Int64(Date().timeIntervalSince1970))
                currentMO.lastLocalEditTimestamp = newTS
                shadowUpdates[uuidStr] = newTS
                needsSave = true
            } else if moTS > localTS {
                // 本地库里的资料较新（他端装置的合法修改）：影子表跟进即可。
                shadowUpdates[uuidStr] = moTS
            }
        }
        if !shadowUpdates.isEmpty {
            var newShadowMap = shadowMap
            shadowUpdates.forEach { newShadowMap[$0.key] = $0.value }
            Defaults[.pzProfilesLastLocalEditTimestamps] = newShadowMap
        }
        if needsSave {
            do {
                try modelContext.save()
            } catch {
                PZLog.error("[PZProfileActor] arbitrateProfilesAgainstUserDefaults: \(error)")
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileActor {
    /// 仅供单元测试：模拟 CloudKit 将过期资料回滚进本地库的情形（不盖章、不写影子表）。
    internal func debugSimulateStaleOverwrite(
        _ profile: PZProfileSendable,
        timestamp: Int64
    ) throws {
        try modelContext.transaction {
            let existing = try modelContext.fetch(FetchDescriptor<PZProfileMO>())
            guard let matched = existing.first(where: { $0.uuid == profile.uuid }) else { return }
            matched.inherit(from: profile)
            matched.lastLocalEditTimestamp = timestamp
        }
    }
}
#endif
