// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
@preconcurrency import CoreData
import Defaults
import Foundation
import PZBaseKit
import SwiftData

// MARK: - PZProfileActor

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
            NotificationCenter.default.publisher(for: ModelContext.didSave)
                .sink(receiveValue: { notification in
                    if let userInfo = notification.userInfo {
                        let inserted = (userInfo["inserted"] as? [PersistentIdentifier]) ?? []
                        let deleted = (userInfo["deleted"] as? [PersistentIdentifier]) ?? []
                        let updated = (userInfo["updated"] as? [PersistentIdentifier]) ?? []
                        print(userInfo)
                        guard !(inserted + deleted + updated).isEmpty else { return }
                        Task { @MainActor in
                            if Defaults[.automaticallyDeduplicatePZProfiles] {
                                _ = try await self.deduplicate()
                            }
                            await self.syncAllDataToUserDefaults()
                        }
                    }
                })
                .store(in: &Self.cancellables)
        }
    }

    // MARK: Public

    public static let shared = PZProfileActor()

    public static let schema = Schema([PZProfileMO.self])

    public static var modelConfig: ModelConfiguration {
        if Pizza.isAppStoreRelease {
            let useGroupContainer = Defaults[.situatePZProfileDBIntoGroupContainer]
            return ModelConfiguration(
                "PZProfileMODB",
                schema: Self.schema,
                isStoredInMemoryOnly: false,
                groupContainer: useGroupContainer ? .identifier(appGroupID) : .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        } else {
            return ModelConfiguration(
                schema: Self.schema,
                isStoredInMemoryOnly: false,
                groupContainer: .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        }
    }

    public static func makeContainer() -> (container: ModelContainer, isReset: Bool) {
        let config = Self.modelConfig
        do {
            return (try ModelContainer(for: Self.schema, configurations: [config]), false)
        } catch {
            secondAttempt: do {
                try FileManager.default.removeItem(at: config.url)
                Defaults[.lastTimeResetLocalProfileDB] = .now
                do {
                    return (try ModelContainer(for: Self.schema, configurations: [config]), true)
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
                    schema: Self.schema,
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

    private static var cancellables: [AnyCancellable] = []
}

// MARK: - AccountMO Related.

extension PZProfileActor {
    @MainActor
    public static func hasOldAccountDataDetected() -> Bool {
        let count = try? AccountMOSputnik.shared.countAllAccountDataAsPZProfileMO()
        return (count ?? 0) > 0
    }

    @MainActor
    public static func migrateOldAccountsIntoProfiles(
        resetNotifications: Bool = true, isUnattended: Bool = false
    ) throws {
        let context = Self.shared.modelContainer.mainContext
        let allExistingUUIDs: [String] = try context.fetch(FetchDescriptor<PZProfileMO>())
            .map(\.uuid.uuidString)
        let oldData = try AccountMOSputnik.shared.allAccountDataAsPZProfileMO()
        var profilesMigratedCount = 0
        oldData.forEach { theEntry in
            if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                guard !isUnattended else { return }
                theEntry.uuid = .init()
                theEntry.name += " (Imported)"
            }
            context.insert(theEntry)
            PZNotificationCenter.bleachNotificationsIfDisabled(for: theEntry.asSendable)
            profilesMigratedCount += 1
        }
        if resetNotifications, profilesMigratedCount > 0 {
            Broadcaster.shared.requireOSNotificationCenterAuthorization()
            Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
        }
        try context.save()
        Task {
            await Self.shared.syncAllDataToUserDefaults()
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
        let result = (try? modelContext.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        return result.sorted { $0.priority < $1.priority }
    }

    public static func getSendableProfiles() -> [PZProfileSendable] {
        let context = ModelContext(shared.modelContainer)
        let result = (try? context.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        return result.sorted { $0.priority < $1.priority }
    }

    public func migrateOldAccountMatchingUUID(_ uuid: String) async throws {
        let profiles = getSendableProfiles()
        let firstMatched = profiles.first { $0.uuid.uuidString == uuid }
        guard firstMatched == nil else { return }
        guard let newProfile = try? await AccountMOSputnik.shared.queryAccountDataMO(uuid: uuid) else { return }
        modelContext.insert(newProfile.asMO)
        try modelContext.save()
        PZNotificationCenter.bleachNotificationsIfDisabled(for: newProfile)
        Defaults[.pzProfiles][newProfile.uuid.uuidString] = newProfile
        UserDefaults.profileSuite.synchronize()
    }
}

// MARK: - Backup and Restore

extension PZProfileActor {
    public func syncAllDataToUserDefaults() {
        var existingKeys = Set<String>(Defaults[.pzProfiles].keys)
        let profiles = getSendableProfiles()
        profiles.forEach {
            Defaults[.pzProfiles][$0.uuid.uuidString] = $0
            existingKeys.remove($0.uuid.uuidString)
        }
        existingKeys.forEach { Defaults[.pzProfiles].removeValue(forKey: $0) }
        UserDefaults.profileSuite.synchronize()
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

extension PZProfileActor {
    /// Warning: 该方法仅对 SwiftData 资料库有操作，不影响 UserDefaults。
    /// - Returns: 是否确实做了去除重复内容的操作。
    @discardableResult
    public func deduplicate() throws -> Bool {
        let existingMOs = (try modelContext.fetch(FetchDescriptor<PZProfileMO>()))
        let existingProfiles = existingMOs.map(\.asSendable).sorted { $0.uuid < $1.uuid }
        var profileSets = Set<PZProfileSendable>(existingProfiles)
        let uniqueProfiles = profileSets.sorted { $0.uuid < $1.uuid }
        /// 用这一行来判断是否有重复内容。没有的话就直接放弃处理。
        guard existingProfiles != uniqueProfiles else { return false }
        profileSets.removeAll()
        try modelContext.transaction {
            existingMOs.forEach { currentMO in
                let sendableProfile = currentMO.asSendable
                if !profileSets.contains(sendableProfile) {
                    profileSets.insert(sendableProfile)
                } else {
                    modelContext.delete(currentMO)
                }
            }
        }
        return true
    }
}
