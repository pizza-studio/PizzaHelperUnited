// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKitShared
import PZProfileCDMOBackports
import Sworm

public typealias CDProfileMOActor = PZCoreDataKit.CDProfileMOActor

extension CDProfileMOActor {
    @MainActor public static var shared: CDProfileMOActor? {
        guard !Pizza.isAppStoreReleaseAsLatteHelper else { return nil }
        if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
            return nil
        }
        guard !Pizza.isNotMainApp else { return nil }
        guard case let .success(result) = singleton else { return nil }
        return result
    }

    public static let singleton: Result<CDProfileMOActor, Error> = {
        let useGroupContainer = Defaults[.situatePZProfileDBIntoGroupContainer]
        do {
            let result = try CDProfileMOActor(
                persistence: .cloud,
                backgroundContext: true,
                useGroupContainer: useGroupContainer
            )
            return .success(result)
        } catch let firstError {
            #if DEBUG
            PZLog.debug("----------------")
            PZLog.debug(
                "CDProfileMOActor failed from booting with useGroupContainer: \(useGroupContainer)."
            )
            PZLog.debug("\(firstError)")
            PZLog.debug("----------------")
            #endif
            guard useGroupContainer else { return .failure(firstError) }
            // Defaults[.situatePZProfileDBIntoGroupContainer] = false
            do {
                let result = try CDProfileMOActor(
                    persistence: .cloud,
                    backgroundContext: true,
                    useGroupContainer: false
                )
                return .success(result)
            } catch let secondError {
                #if DEBUG
                PZLog.debug("----------------")
                PZLog.debug("CDProfileMOActor failed from final booting.")
                PZLog.debug("This attempt doesn't use useGroupContainer.")
                PZLog.debug("\(secondError)")
                PZLog.debug("----------------")
                #endif
                return .failure(secondError)
            }
        }
    }()
}

// MARK: - CDProfileMOActor + PZProfileActorProtocol

extension CDProfileMOActor: PZProfileActorProtocol {
    public func acceptMigratedOldAccountProfiles(
        oldData: [PZProfileSendable],
        resetNotifications: Bool = true,
        isUnattended: Bool = false
    ) async throws {
        try container.perform { context in
            let allExistingCDMOObjs = try context.fetch(PZProfileCDMO.all)
            let allExistingCDMOs = try allExistingCDMOObjs.map { try $0.decode() }
            let allExistingUUIDs: [String] = allExistingCDMOs.map(\.uuid.uuidString)
            var currentPriorityID = (allExistingCDMOs.map(\.priority).max() ?? 0) + 1
            var profilesMigratedCount = 0
            let nowTimestamp = Int(Date().timeIntervalSince1970)
            try oldData.forEach { theEntrySendable in
                var theEntry = theEntrySendable.asCDMO
                theEntry.priority = currentPriorityID
                theEntry.lastLocalEditTimestamp = nowTimestamp
                if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                    guard !isUnattended else { return }
                    theEntry.uuid = .init()
                    theEntry.name += " (Imported)"
                }
                try context.insert(theEntry)
                self.recordLocalEditTimestamp(
                    Int64(nowTimestamp),
                    uuidString: theEntry.uuid.uuidString
                )
                PZNotificationCenter.bleachNotificationsIfDisabled(for: theEntry.asSendable)
                profilesMigratedCount += 1
                currentPriorityID += 1
            }
            self.syncAllDataToUserDefaults()
            if resetNotifications, profilesMigratedCount > 0 {
                Task {
                    guard #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) else { return }
                    await Broadcaster.shared.requireOSNotificationCenterAuthorization()
                    await Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                }
            }
        }
    }

    public func getSendableProfiles() -> [PZProfileSendable] {
        let fetched = try? container.perform { context in
            try context.fetch(PZProfileCDMO.all).compactMap { obj in
                try obj.decode().asSendable
            }
        }
        guard var result = fetched else { return [] }
        result.fixPrioritySettings(respectExistingPriority: true)
        return result.sorted { $0.priority < $1.priority }
    }

    private func addOrUpdateProfileSansCommission(
        _ profileSendable: PZProfileSendable,
        against context: ManagedObjectContext
    ) throws {
        let existingObjs = try context.fetch(PZProfileCDMO.all)
        var matchedExistingObjs: [ManagedObject<PZProfileCDMO>] = existingObjs.filter {
            (try? $0.decode())?.uuid.uuidString == profileSendable.uuid.uuidString
        }
        let nowTimestamp = Int(Date().timeIntervalSince1970)
        var existingDataUpdatedSuccessfully = false
        deduplicateAndUpdate: while let lastObj = matchedExistingObjs.last {
            if matchedExistingObjs.count > 1 {
                context.delete(lastObj)
                matchedExistingObjs.removeLast()
            } else {
                lastObj.encode(profileSendable.asCDMO)
                lastObj.encode(\.lastLocalEditTimestamp, nowTimestamp)
                existingDataUpdatedSuccessfully = true
                break deduplicateAndUpdate
            }
        }
        if !existingDataUpdatedSuccessfully {
            var cdmo = profileSendable.asCDMO
            cdmo.lastLocalEditTimestamp = nowTimestamp
            try context.insert(cdmo)
        }
        recordLocalEditTimestamp(Int64(nowTimestamp), uuidString: profileSendable.uuid.uuidString)
    }

    public func addOrUpdateProfile(_ profileSendable: PZProfileSendable) throws {
        try container.perform { context in
            try self.addOrUpdateProfileSansCommission(profileSendable, against: context)
        }
    }

    public func addOrUpdateProfilesWithDeletion(
        _ profileSendableSet: Set<PZProfileSendable>,
        uuidsToDelete: Set<UUID>
    ) throws {
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                let currentCDMO = try currentCDMOObj.decode()
                guard uuidsToDelete.contains(currentCDMO.uuid) else { return }
                context.delete(currentCDMOObj)
            }
            try profileSendableSet.sorted {
                $0.priority < $1.priority
            }.forEach { profileSendable in
                try self.addOrUpdateProfileSansCommission(profileSendable, against: context)
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
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                let currentCDMO = try currentCDMOObj.decode()
                guard uuids.contains(currentCDMO.uuid) else {
                    remainingProfiles.insert(currentCDMO.asSendable)
                    return
                }
                context.delete(currentCDMOObj)
            }
        }
        removeLocalEditTimestamps(uuidStrings: uuids.map(\.uuidString))
        return remainingProfiles
    }

    @discardableResult
    public func bleachInvalidProfiles() throws -> Set<PZProfileSendable> {
        var deletedProfiles = Set<PZProfileSendable>()
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                let currentCDMO = try currentCDMOObj.decode()
                guard currentCDMO.isInvalid else { return }
                context.delete(currentCDMOObj)
                deletedProfiles.insert(currentCDMO.asSendable)
            }
        }
        removeLocalEditTimestamps(uuidStrings: deletedProfiles.map(\.uuid.uuidString))
        return deletedProfiles
    }

    /// Warning: 该方法仅对 SwiftData 资料库有操作，不影响 UserDefaults。
    @discardableResult
    public func deduplicate() throws
        -> (removed: Set<PZProfileSendable>, left: Set<PZProfileSendable>) {
        var (profilesRemoved, profileLeft) = (Set<PZProfileSendable>(), Set<PZProfileSendable>())
        try container.perform { context in
            var existingCDMOObjs = try context.fetch(PZProfileCDMO.all)
            try existingCDMOObjs.sort { try $0.decode().priority < $1.decode().priority }
            let existingCDMOs = try existingCDMOObjs.map { try $0.decode() }
            let existingProfiles = existingCDMOs.map(\.asSendable)
            var profileSet = Set<PZProfileSendable>(existingProfiles)
            let uniqueProfiles = profileSet
            /// 用这一行来判断是否有重复内容。没有的话就直接放弃处理。
            if Set(existingProfiles) == Set(uniqueProfiles) {
                profilesRemoved = .init()
                profileLeft = profileSet
            } else {
                profileSet.removeAll()
                var profilesRemoved: Set<PZProfileSendable> = .init()
                try existingCDMOObjs.forEach { currentCDMOObj in
                    let sendableProfile = try currentCDMOObj.decode().asSendable
                    if !profileSet.contains(sendableProfile) {
                        profileSet.insert(sendableProfile)
                    } else {
                        context.delete(currentCDMOObj)
                        profilesRemoved.insert(sendableProfile)
                    }
                }
                profileLeft = profileSet
            }
        }
        return (profilesRemoved, profileLeft)
    }

    public func propagateDeviceFingerprint(_ fingerprint: String) throws {
        guard !fingerprint.isEmpty else { return }
        let nowTimestamp = Int(Date().timeIntervalSince1970)
        var stampedUUIDs: [String] = []
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                switch try currentCDMOObj.decode().server.region {
                case .hoyoLab: return
                case .miyoushe:
                    currentCDMOObj.encode(\.deviceFingerPrint, fingerprint)
                    currentCDMOObj.encode(\.lastLocalEditTimestamp, nowTimestamp)
                    if let uuidStr = try? currentCDMOObj.decode().uuid.uuidString {
                        stampedUUIDs.append(uuidStr)
                    }
                }
            }
        }
        stampedUUIDs.forEach { recordLocalEditTimestamp(Int64(nowTimestamp), uuidString: $0) }
    }
}

// MARK: - Local Edit Timestamp & Stale Data Arbitration.

extension CDProfileMOActor {
    /// 以 UserDefaults 内的副本与各资料最近接受本地修改的时间戳为据，
    /// 裁决并丢弃过期的资料变动（例如 CloudKit 导入造成的回滚）。
    ///
    /// - 本地库里的时间戳较旧：判定为过期资料，以 UserDefaults 副本写回。
    /// - 本地库里的时间戳较新：判定为他端装置的合法修改，予以接受并让影子表跟进。
    public func arbitrateProfilesAgainstUserDefaults() async {
        let shadowMap = Defaults[.pzProfilesLastLocalEditTimestamps]
        guard !shadowMap.isEmpty else { return }
        let backupMap = Defaults[.pzProfiles]
        try? container.perform { context in
            let existingObjs = try context.fetch(PZProfileCDMO.all)
            var shadowUpdates: [String: Int64] = [:]
            for currentObj in existingObjs {
                let currentCDMO = try currentObj.decode()
                let uuidStr = currentCDMO.uuid.uuidString
                let localTS = shadowMap[uuidStr] ?? 0
                let moTS = Int64(currentCDMO.lastLocalEditTimestamp ?? 0)
                if moTS < localTS {
                    // 本地库里的资料已过期（可能被 CloudKit 回滚）：以 UserDefaults 副本写回。
                    guard let backup = backupMap[uuidStr] else { continue }
                    var restored = backup.asCDMO
                    let newTS = max(localTS, Int64(Date().timeIntervalSince1970))
                    restored.lastLocalEditTimestamp = Int(newTS)
                    currentObj.encode(restored)
                    shadowUpdates[uuidStr] = newTS
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
        }
    }
}

#if DEBUG
extension CDProfileMOActor {
    /// 仅供单元测试：模拟 CloudKit 将过期资料回滚进本地库的情形（不盖章、不写影子表）。
    internal func debugSimulateStaleOverwrite(
        _ profile: PZProfileSendable,
        timestamp: Int64
    ) throws {
        try container.perform { context in
            let existing = try context.fetch(PZProfileCDMO.all)
            guard let matched = try existing.first(where: { try $0.decode().uuid == profile.uuid })
            else { return }
            var cdmo = profile.asCDMO
            cdmo.lastLocalEditTimestamp = Int(timestamp)
            matched.encode(cdmo)
        }
    }
}
#endif
