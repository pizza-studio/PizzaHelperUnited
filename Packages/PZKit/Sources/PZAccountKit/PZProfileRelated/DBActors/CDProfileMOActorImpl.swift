// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZCoreDataKitShared
import PZProfileCDMOBackports
import Sworm

public typealias CDProfileMOActor = PZCoreDataKit.CDProfileMOActor

extension CDProfileMOActor {
    public static var shared: CDProfileMOActor? {
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
            print("----------------")
            print("CDProfileMOActor failed from booting with useGroupContainer: \(useGroupContainer).")
            print(firstError)
            print("----------------")
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
                print("----------------")
                print("CDProfileMOActor failed from final booting.")
                print("This attempt doesn't use useGroupContainer.")
                print(secondError)
                print("----------------")
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
            try oldData.forEach { theEntrySendable in
                var theEntry = theEntrySendable.asCDMO
                theEntry.priority = currentPriorityID
                if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                    guard !isUnattended else { return }
                    theEntry.uuid = .init()
                    theEntry.name += " (Imported)"
                }
                try context.insert(theEntry)
                PZNotificationCenter.bleachNotificationsIfDisabled(for: theEntry.asSendable)
                profilesMigratedCount += 1
                currentPriorityID += 1
            }
            self.syncAllDataToUserDefaults()
            if resetNotifications, profilesMigratedCount > 0 {
                Task {
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

    private func addOrUpdateProfile(
        _ profileSendable: PZProfileSendable,
        against context: ManagedObjectContext
    ) throws {
        var matchedExistingObjs = try context.fetch(
            PZProfileCDMO.all.where(\PZProfileCDMO.uuid == profileSendable.uuid)
        )
        var existingDataUpdatedSuccessfully = false
        deduplicateAndUpdate: while let lastObj = matchedExistingObjs.last {
            if matchedExistingObjs.count > 1 {
                context.delete(lastObj)
                matchedExistingObjs.removeLast()
            } else {
                lastObj.encode(profileSendable.asCDMO)
                existingDataUpdatedSuccessfully = true
                break deduplicateAndUpdate
            }
        }
        if !existingDataUpdatedSuccessfully {
            try context.insert(profileSendable.asCDMO)
        }
    }

    public func addOrUpdateProfiles(_ profileSendableSet: Set<PZProfileSendable>) throws {
        try container.perform { context in
            try profileSendableSet.sorted {
                $0.priority < $1.priority
            }.forEach { profileSendable in
                try self.addOrUpdateProfile(profileSendable, against: context)
            }
        }
    }

    public func addOrUpdateProfile(_ profileSendable: PZProfileSendable) throws {
        try container.perform { context in
            try self.addOrUpdateProfile(profileSendable, against: context)
        }
    }

    public func replaceAllProfiles(with profileSendableSet: Set<PZProfileSendable>) throws {
        var map: [UUID: PZProfileSendable] = [:]
        var handledUUIDs = Set<UUID>()
        profileSendableSet.forEach {
            map[$0.uuid] = $0
        }
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                var currentCDMO = try currentCDMOObj.decode()
                guard let matchedSendable = map[currentCDMO.uuid] else {
                    context.delete(currentCDMOObj)
                    return
                }
                currentCDMO.inherit(from: matchedSendable)
                currentCDMOObj.encode(currentCDMO)
                handledUUIDs.insert(matchedSendable.uuid)
            }
            let restUUIDs = Set(profileSendableSet.map(\.uuid)).subtracting(handledUUIDs)
            let restProfilesToAdd: [PZProfileCDMO] = restUUIDs.compactMap { map[$0]?.asCDMO }
            try restProfilesToAdd.forEach { try context.insert($0) }
        }
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
        try container.perform { context in
            try context.fetch(PZProfileCDMO.all).forEach { currentCDMOObj in
                switch try currentCDMOObj.decode().server.region {
                case .hoyoLab: return
                case .miyoushe:
                    currentCDMOObj.encode(\.deviceFingerPrint, fingerprint)
                }
            }
        }
    }
}
