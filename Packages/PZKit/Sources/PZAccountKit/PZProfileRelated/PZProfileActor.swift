// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
@preconcurrency import Defaults
import Foundation
import PZBaseKit
import SwiftData

extension Defaults.Keys {
    public static let lastTimeResetLocalProfileDB = Key<Date?>(
        "lastTimeResetLocalProfileDB",
        default: nil,
        suite: .baseSuite
    )
}

// MARK: - PZProfileActor

@ModelActor
public actor PZProfileActor {
    // MARK: Lifecycle

    public init(unitTests: Bool = false) {
        modelContainer = unitTests ? Self.makeContainer4UnitTests() : Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    public static let shared = PZProfileActor()

    public static let schema = Schema([PZProfileMO.self])

    public static var modelConfig: ModelConfiguration {
        if Pizza.isAppStoreRelease {
            return ModelConfiguration(
                "PZProfileMODB",
                schema: Self.schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(appGroupID),
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

    public static func makeContainer() -> ModelContainer {
        let config = Self.modelConfig
        do {
            return try ModelContainer(for: Self.schema, configurations: [config])
        } catch {
            secondAttempt: do {
                try FileManager.default.removeItem(at: config.url)
                Defaults[.lastTimeResetLocalProfileDB] = .now
                do {
                    return try ModelContainer(for: Self.schema, configurations: [config])
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
}

// MARK: - AccountMO Related.

extension PZProfileActor {
    @MainActor
    public static func hasOldAccountDataDetected() -> Bool {
        let count = try? AccountMOSputnik.shared.countAllAccountDataAsPZProfileMO()
        return (count ?? 0) > 0
    }

    @MainActor
    public static func migrateOldAccountsIntoProfiles(resetNotifications: Bool = true) throws {
        let context = Self.shared.modelContainer.mainContext
        let allExistingUUIDs: [String] = try context.fetch(FetchDescriptor<PZProfileMO>())
            .map(\.uuid.uuidString)
        let oldData = try AccountMOSputnik.shared.allAccountDataAsPZProfileMO()
        var count = 0
        oldData.forEach { theEntry in
            if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                theEntry.uuid = .init()
                theEntry.name += " (Imported)"
            }
            context.insert(theEntry)
            count += 1
        }
        if resetNotifications, count > 0 {
            Broadcaster.shared.requireOSNotificationCenterAuthorization()
            Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
        }
        try context.save()
    }

    /// An OOBE task attempts inheriting old AccountMOs from the previous Pizza Apps using obsolete engines.
    /// - Parameter resetNotifications: Recheck permissions for notifications && reload all timelines across widgets.
    @MainActor
    public static func attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: Bool = true) {
        guard Pizza.isAppStoreRelease, !Defaults[.oldAccountMOAlreadyAutoInherited] else { return }
        do {
            try migrateOldAccountsIntoProfiles(resetNotifications: resetNotifications)
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
    }
}
