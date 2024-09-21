// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Foundation
import PZBaseKit
import SwiftData

// MARK: - PZProfileActor

@ModelActor
public actor PZProfileActor {
    // MARK: Lifecycle

    public init() {
        modelContainer = Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    @MainActor public static let shared = PZProfileActor()

    public static let schema = Schema([PZProfileMO.self])

    public static var modelConfig: ModelConfiguration {
        ModelConfiguration(
            schema: Self.schema,
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }

    public static func makeContainer() -> ModelContainer {
        let config = Self.modelConfig
        do {
            return try ModelContainer(for: Self.schema, configurations: [config])
        } catch {
            secondAttempt: do {
                try FileManager.default.removeItem(at: config.url)
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
}

// MARK: - AccountMO Related.

extension PZProfileActor {
    @MainActor
    public static func hasOldAccountDataDetected() -> Bool {
        let count = try? AccountMOSputnik.shared.countAllAccountDataAsPZProfileMO()
        return (count ?? 0) > 0
    }

    @MainActor
    public static func migrateOldAccountsIntoProfiles() throws {
        let context = Self.shared.modelContainer.mainContext
        let allExistingUUIDs: [String] = try context.fetch(FetchDescriptor<PZProfileMO>())
            .map(\.uuid.uuidString)
        let oldData = try AccountMOSputnik.shared.allAccountDataAsPZProfileMO()
        oldData.forEach { theEntry in
            if allExistingUUIDs.contains(theEntry.uuid.uuidString) {
                theEntry.uuid = .init()
                theEntry.name += " (Imported)"
            }
            context.insert(theEntry)
        }
        try context.save()
    }
}
