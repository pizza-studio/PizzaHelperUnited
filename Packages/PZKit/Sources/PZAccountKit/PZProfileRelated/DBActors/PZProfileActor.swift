// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Defaults
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
                } else {
                    await syncAllDataToUserDefaults()
                }
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
            secondAttempt: do {
                try FileManager.default.removeItem(at: config.url)
                Defaults[.lastTimeResetLocalProfileDB] = .now
                do {
                    return (try ModelContainer(for: Schema([PZProfileMO.self]), configurations: [config]), true)
                } catch {
                    break secondAttempt
                }
            } catch {
                fatalError(
                    "Could not remove wrecked PZProfileMO ModelContainer at \(config.url.absoluteString). Error: \(error)"
                )
            }
            fatalError("Could not create PZProfileMO ModelContainer at \(config.url.absoluteString). Error: \(error)")
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
        try modelContext.transaction {
            oldData.forEach { theEntrySendable in
                let theEntry = theEntrySendable.asMO
                theEntry.priority = currentPriorityID
                if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                    guard !isUnattended else { return }
                    theEntry.uuid = .init()
                    theEntry.name += " (Imported)"
                }
                modelContext.insert(theEntry)
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
        var existingDataUpdatedSuccessfully = false
        deduplicateAndUpdate: while let lastObj = matchedExistingObjs.last {
            if matchedExistingObjs.count > 1 {
                context.delete(lastObj)
                matchedExistingObjs.removeLast()
            } else {
                lastObj.inherit(from: profileSendable)
                existingDataUpdatedSuccessfully = true
                break deduplicateAndUpdate
            }
        }
        if !existingDataUpdatedSuccessfully {
            context.insert(profileSendable.asMO)
        }
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
            try uuidsToDelete.forEach { uuid in
                try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                    guard uuidsToDelete.contains(currentMO.uuid) else { return }
                    modelContext.delete(currentMO)
                }
            }
            try profileSendableSet.sorted {
                $0.priority < $1.priority
            }.forEach {
                try addOrUpdateProfileSansCommission($0, against: modelContext)
            }
        }
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
        return remainingProfiles
    }

    @discardableResult
    public func bleachInvalidProfiles() throws -> Set<PZProfileSendable> {
        var deletedProfiles = Set<PZProfileSendable>()
        try modelContext.transaction {
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard currentMO.isInvalid else { return }
                modelContext.delete(currentMO)
                deletedProfiles.insert(currentMO.asSendable)
            }
        }
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
            print(error)
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
        try modelContext.transaction {
            existingMOs.forEach { currentMO in
                switch currentMO.server.region {
                case .hoyoLab: return
                case .miyoushe:
                    currentMO.deviceFingerPrint = fingerprint
                }
            }
        }
    }
}
