// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaKit
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - PersistenceController

@ModelActor
public actor PersistenceController {
    // MARK: Lifecycle

    @MainActor
    public init() {
        self.modelContainer = Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    @MainActor public static let shared = PersistenceController()

    @MainActor public static let accountMOSputnik: AccountMOSputnik = try! AccountMOSputnik(
        persistence: .cloud,
        backgroundContext: false
    )

    @MainActor public static let cdGachaMOSputnik: CDGachaMOSputnik = try! CDGachaMOSputnik(
        persistence: .cloud,
        backgroundContext: false
    )
}

extension PersistenceController {
    public static func makeContainer() -> ModelContainer {
        let schema = Schema([
            PZProfileMO.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    @MainActor
    public static func hasOldAccountDataDetected() -> Bool {
        let count = try? Self.accountMOSputnik.countAllAccountDataAsPZProfileMO()
        return (count ?? 0) > 0
    }

    @MainActor
    public static func migrateOldAccountsIntoProfiles() throws {
        let context = Self.shared.modelContainer.mainContext
        let allExistingUUIDs: [String] = try context.fetch(FetchDescriptor<PZProfileMO>())
            .map(\.uuid.uuidString)
        let oldData = try Self.accountMOSputnik.allAccountDataAsPZProfileMO()
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
