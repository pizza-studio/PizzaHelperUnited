// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Defaults
import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts
import SwiftData

// MARK: - PZProfileActor

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
@ModelActor
public actor PZProfileActor {
    // MARK: Lifecycle

    public init(unitTests: Bool = false) {
        var isReset = false
        if unitTests {
            modelContainer = Self.makeContainer4UnitTests()
        } else {
            let newContainer = Self.makeContainer()
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

    // MARK: Public

    public static let shared = PZProfileActor()

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

    // MARK: Private
}

// MARK: - AccountMO Related.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileActor {
    private func acceptMigratedOldAccountProfiles(
        oldData: [PZProfileSendable],
        resetNotifications: Bool = true,
        isUnattended: Bool = false
    ) async throws {
        let allExistingMOs = try modelContext.fetch(FetchDescriptor<PZProfileMO>()).sorted {
            $0.priority < $1.priority
        }
        let allExistingUUIDs: [String] = allExistingMOs.map(\.uuid.uuidString)
        var currentPriorityID = (allExistingMOs.map(\.priority).max() ?? 0) + 1
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

    @MainActor
    public static func migrateOldAccountsIntoProfiles(
        resetNotifications: Bool = true, isUnattended: Bool = false
    ) throws {
        let oldData = try AccountMOSputnik.shared.getAllAccountDataAsPZProfileSendable()
        Task {
            do {
                try await PZProfileActor.shared.acceptMigratedOldAccountProfiles(
                    oldData: oldData,
                    resetNotifications: resetNotifications,
                    isUnattended: isUnattended
                )
            } catch {
                return
            }
        }
    }

    /// An OOBE task attempts inheriting old AccountMOs from the previous Pizza Apps using obsolete engines.
    /// - Parameter resetNotifications: Recheck permissions for notifications && reload all timelines across widgets.
    @MainActor
    public static func attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: Bool = true) {
        guard Pizza.isAppStoreRelease, !Defaults[.oldAccountMOAlreadyAutoInherited] else { return }
        do {
            try migrateOldAccountsIntoProfiles(
                resetNotifications: resetNotifications,
                isUnattended: true
            )
        } catch {
            return
        }
        Defaults[.oldAccountMOAlreadyAutoInherited] = true
    }

    public func getSendableProfiles() -> [PZProfileSendable] {
        var result = (try? modelContext.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        result.fixPrioritySettings(respectExistingPriority: true)
        return result.sorted { $0.priority < $1.priority }
    }

    private func addProfile(_ profileSendable: PZProfileSendable, commitAfterDone: Bool = true) throws {
        func subTask() throws {
            var isAdded = false
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard !isAdded else { return }
                switch currentMO.uuid == profileSendable.uuid {
                case true:
                    currentMO.inherit(from: profileSendable)
                    isAdded = true
                case false:
                    break
                }
            }
            if !isAdded {
                modelContext.insert(profileSendable.asMO)
            }
        }
        if commitAfterDone {
            try modelContext.transaction {
                try subTask()
            }
        } else {
            try subTask()
        }
    }

    public func addProfiles(
        _ profileSendableSet: Set<PZProfileSendable>
    ) throws {
        try modelContext.transaction {
            try profileSendableSet.sorted {
                $0.priority < $1.priority
            }.forEach {
                try addProfile($0, commitAfterDone: false)
            }
        }
    }

    /// This will add the profile if it is not already added.
    public func updateProfile(_ profileSendable: PZProfileSendable) throws {
        try modelContext.transaction {
            var processed = false
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard currentMO.uuid == profileSendable.uuid else { return }
                currentMO.inherit(from: profileSendable)
                processed = true
            }
            if !processed {
                modelContext.insert(profileSendable.asMO)
            }
        }
    }

    public func replaceAllProfiles(with profileSendableSet: Set<PZProfileSendable>) throws {
        var map: [UUID: PZProfileSendable] = [:]
        var handledUUIDs = Set<UUID>()
        profileSendableSet.forEach {
            map[$0.uuid] = $0
        }

        try modelContext.transaction {
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard let matchedSendable = map[currentMO.uuid] else {
                    modelContext.delete(currentMO)
                    return
                }
                currentMO.inherit(from: matchedSendable)
                handledUUIDs.insert(matchedSendable.uuid)
            }
            let restUUIDs = Set(profileSendableSet.map(\.uuid)).subtracting(handledUUIDs)
            let restProfilesToAdd: [PZProfileMO] = restUUIDs.compactMap { map[$0]?.asMO }
            restProfilesToAdd.forEach(modelContext.insert)
        }
    }

    public func deleteProfile(uuid: UUID) throws {
        try modelContext.transaction {
            try modelContext.enumerate(FetchDescriptor<PZProfileMO>()) { currentMO in
                guard currentMO.uuid == uuid else { return }
                modelContext.delete(currentMO)
            }
        }
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

    public static func getSendableProfiles() -> [PZProfileSendable] {
        let context = ModelContext(shared.modelContainer)
        let result = (try? context.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        return result.sorted { $0.priority < $1.priority }
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileActor {
    @discardableResult
    public func syncAllDataToUserDefaults() -> [PZProfileSendable] {
        var existingKeys = Set<String>(Defaults[.pzProfiles].keys)
        let profiles = getSendableProfiles()
        profiles.forEach {
            Defaults[.pzProfiles][$0.uuid.uuidString] = $0
            existingKeys.remove($0.uuid.uuidString)
        }
        existingKeys.forEach { Defaults[.pzProfiles].removeValue(forKey: $0) }
        UserDefaults.profileSuite.synchronize()
        return profiles
    }

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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileActor {
    /// Warning: 该方法仅对 SwiftData 资料库有操作，不影响 UserDefaults。
    @discardableResult
    public func deduplicate() throws
        -> (removed: Set<PZProfileSendable>, left: Set<PZProfileSendable>) {
        let existingMOs = (try modelContext.fetch(FetchDescriptor<PZProfileMO>()))
        let existingProfiles = existingMOs.map(\.asSendable).sorted { $0.uuid < $1.uuid }
        var profileSet = Set<PZProfileSendable>(existingProfiles)
        let uniqueProfiles = profileSet.sorted { $0.uuid < $1.uuid }
        /// 用这一行来判断是否有重复内容。没有的话就直接放弃处理。
        guard existingProfiles != uniqueProfiles else {
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
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
