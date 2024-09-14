// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaKit
import GachaMetaDB
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

    public static func makeContainer() -> ModelContainer {
        let schema = Schema([
            PZProfileMO.self, PZGachaEntryMO.self,
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
}

// MARK: - AccountMO Related.

extension PersistenceController {
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

// MARK: - CDGachaMO Related.

extension PersistenceController {
    @MainActor
    public static func hasOldGachaDataDetected() -> Bool {
        let count = try? CDGachaMOSputnik.shared.countAllCDGachaMOAsPZGachaEntryMO()
        return (count ?? 0) > 0
    }

    @MainActor
    public static func migrateOldGachasIntoProfiles() throws {
        let context = Self.shared.modelContainer.mainContext
        let allExistingEntryIDs: [String] = try context.fetch(FetchDescriptor<PZGachaEntryMO>()).map(\.id)
        let oldData = try CDGachaMOSputnik.shared.allCDGachaMOAsPZGachaEntryMO()
        oldData.forEach { theEntry in
            if !allExistingEntryIDs.contains(theEntry.id) {
                context.insert(theEntry)
            }
        }
        try context.save()
    }

    @MainActor
    public static func command4InheritingOldGachaRecord() -> Void? {
        if PersistenceController.hasOldGachaDataDetected() {
            return try? PersistenceController.migrateOldGachasIntoProfiles()
        } else {
            return nil
        }
    }
}
