// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - GachaActor

@ModelActor
public actor GachaActor {
    // MARK: Lifecycle

    public init() {
        self.modelContainer = Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Public

    @MainActor public static let shared = GachaActor()
    public static let sharedBg = GachaActor()

    public static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZGachaEntryMO.self, PZGachaProfileMO.self,
                configurations: Self.modelConfig4Entries, Self.modelConfig4Profiles
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - Schemes and Configs.

extension GachaActor {
    public static let schema4Entries = Schema([PZGachaEntryMO.self])
    public static let schema4Profiles = Schema([PZGachaProfileMO.self])

    public static var modelConfig4Entries: ModelConfiguration {
        ModelConfiguration(
            "PZGachaEntryMO",
            schema: Schema([PZGachaEntryMO.self]),
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }

    public static var modelConfig4Profiles: ModelConfiguration {
        ModelConfiguration(
            "PZGachaProfileMO",
            schema: Schema([PZGachaProfileMO.self]),
            isStoredInMemoryOnly: false,
            groupContainer: .none,
            cloudKitDatabase: .private(iCloudContainerName)
        )
    }
}

// MARK: - CDGachaMO Related Static Methods.

extension GachaActor {
    @MainActor
    public static func migrateOldGachasIntoProfiles() async throws {
        let oldData = try CDGachaMOSputnik.shared.allCDGachaMOAsPZGachaEntryMO()
        let task = Task {
            try await sharedBg.batchInsert(oldData)
        }
        try await task.value
    }

    public func batchInsert(_ sources: [PZGachaEntryMO]) throws {
        let allExistingEntryIDs: [String] = try modelContext.fetch(FetchDescriptor<PZGachaEntryMO>()).map(\.id)
        var profiles: Set<GachaProfileID> = .init()
        sources.forEach { theEntry in
            if !allExistingEntryIDs.contains(theEntry.id) {
                modelContext.insert(theEntry)
            }
            let profile = GachaProfileID(uid: theEntry.uid, game: theEntry.game)
            if !profiles.contains(profile) {
                profiles.insert(profile)
            }
        }
        try modelContext.save()
        try lazyRefreshProfiles(newProfiles: profiles)
    }

    public func lazyRefreshProfiles(newProfiles: Set<GachaProfileID>? = nil) throws {
        let existingProfiles = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
        var profiles = newProfiles ?? .init()
        existingProfiles.forEach {
            profiles.insert($0.asSendable)
            modelContext.delete($0)
        }
        try modelContext.save()
        let arrProfiles = profiles.sorted { $0.uidWithGame < $1.uidWithGame }
        arrProfiles.forEach { modelContext.insert($0.asMO) }
        try modelContext.save()
    }
}
