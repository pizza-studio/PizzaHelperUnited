// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Foundation
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - GachaActor

@ModelActor
public actor GachaActor {
    // MARK: Lifecycle

    public init(unitTests: Bool = false) {
        modelContainer = unitTests ? Self.makeContainer4UnitTests() : Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
        NotificationCenter.default.publisher(for: ModelContext.didSave)
            .sink(receiveValue: { notification in
                if let userInfo = notification.userInfo {
                    let inserted = (userInfo["inserted"] as? [PersistentIdentifier]) ?? []
                    let deleted = (userInfo["deleted"] as? [PersistentIdentifier]) ?? []
                    let updated = (userInfo["updated"] as? [PersistentIdentifier]) ?? []
                    print(userInfo)
                    guard !(inserted + deleted + updated).isEmpty else { return }
                    Task { @MainActor in
                        if !GachaActor.remoteChangesAvailable {
                            GachaActor.remoteChangesAvailable = true
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Public

    @MainActor public static var remoteChangesAvailable = false

    public let cdGachaMOSputnik = try! CDGachaMOSputnik(persistence: .cloud, backgroundContext: true)

    // MARK: Private

    private var cancellables: [AnyCancellable] = []
}

extension GachaActor {
    public static let shared = GachaActor()

    public static func makeContainer4UnitTests() -> ModelContainer {
        do {
            return try ModelContainer(
                for:
                PZGachaEntryMO.self,
                PZGachaProfileMO.self,
                configurations:
                ModelConfiguration(
                    "PZGachaKitDB",
                    schema: Self.makeSchema(),
                    isStoredInMemoryOnly: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
            )
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
    }

    public static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZGachaEntryMO.self, PZGachaProfileMO.self,
                configurations: Self.modelConfig
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - Schemes and Configs.

extension GachaActor {
    public static func makeSchema() -> Schema {
        Schema([PZGachaEntryMO.self, PZGachaProfileMO.self])
    }

    public static var modelConfig: ModelConfiguration {
        if Pizza.isAppStoreRelease {
            return ModelConfiguration(
                "PZGachaKitDB",
                schema: Self.makeSchema(),
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(appGroupID),
                cloudKitDatabase: .private(iCloudContainerName)
            )
        } else {
            return ModelConfiguration(
                "PZGachaKitDB",
                schema: Self.makeSchema(),
                isStoredInMemoryOnly: false,
                groupContainer: .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        }
    }
}

// MARK: - CDGachaMO Related Static Methods.

extension GachaActor {
    public func migrateOldGachasIntoProfiles() throws {
        let oldData = try cdGachaMOSputnik.allCDGachaMOAsPZGachaEntryMO()
        try batchInsert(
            oldData,
            overrideDuplicatedEntries: false,
            refreshGachaProfiles: true
        )
    }

    public func deleteAllEntriesOfGPID(_ gpid: GachaProfileID) throws {
        try modelContext.transaction {
            let uid = gpid.uid
            let gameStr = gpid.game.rawValue
            try modelContext.delete(
                model: PZGachaEntryMO.self,
                where: #Predicate { matchedEntryMO in
                    matchedEntryMO.uid == uid && matchedEntryMO.game == gameStr
                }
            )
            try modelContext.delete(
                model: PZGachaProfileMO.self,
                where: #Predicate { matchedEntryMO in
                    matchedEntryMO.uid == uid && matchedEntryMO.gameRAW == gameStr
                }
            )
        }
        Task { @MainActor in
            GachaActor.remoteChangesAvailable = false
        }
    }

    @discardableResult
    public func batchInsert(
        _ sources: [PZGachaEntrySendable],
        overrideDuplicatedEntries: Bool = false,
        refreshGachaProfiles: Bool = false
    ) throws
        -> Int {
        var insertedEntriesCount = 0
        try modelContext.transaction {
            var existingIDsDescriptor = FetchDescriptor<PZGachaEntryMO>()
            existingIDsDescriptor.propertiesToFetch = [\.id]
            var allExistingEntryIDs: Set<String> = .init(
                try modelContext.fetch(existingIDsDescriptor).map(\.id)
            )
            if overrideDuplicatedEntries, !allExistingEntryIDs.isEmpty {
                let allNewEntryIDs: Set<String> = .init(sources.map(\.id))
                let entryIDsToRemove = allExistingEntryIDs.intersection(allNewEntryIDs)
                // 注意：空集合在 intersection 其他集合时，结果恐不为空。
                if !entryIDsToRemove.isEmpty {
                    try modelContext.delete(
                        model: PZGachaEntryMO.self,
                        where: #Predicate { matchedEntryMO in
                            entryIDsToRemove.contains(matchedEntryMO.id)
                        }
                    )
                }
                allExistingEntryIDs.subtract(entryIDsToRemove)
            }
            var profiles: Set<GachaProfileID> = .init()
            sources.forEach { theEntry in
                if overrideDuplicatedEntries || !allExistingEntryIDs.contains(theEntry.id) {
                    modelContext.insert(theEntry.asMO)
                    insertedEntriesCount += 1
                }
                let profile = GachaProfileID(uid: theEntry.uid, game: theEntry.gameTyped)
                if !profiles.contains(profile) {
                    profiles.insert(profile)
                }
            }
        }
        Task { @MainActor in
            GachaActor.remoteChangesAvailable = false
        }
        // try lazyRefreshProfiles(newProfiles: profiles)
        if refreshGachaProfiles {
            try refreshAllProfiles()
        }
        return insertedEntriesCount
    }

    public func lazyRefreshProfiles(newProfiles: Set<GachaProfileID>? = nil) throws {
        try modelContext.transaction {
            let existingProfiles = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
            var profiles = newProfiles ?? .init()
            existingProfiles.forEach {
                profiles.insert($0.asSendable)
                modelContext.delete($0)
            }
            let arrProfiles = profiles.sorted { $0.uidWithGame < $1.uidWithGame }
            arrProfiles.forEach { modelContext.insert($0.asMO) }
        }
        Task { @MainActor in
            GachaActor.remoteChangesAvailable = false
        }
    }

    @discardableResult
    public func refreshAllProfiles() throws -> [GachaProfileID] {
        var newProfiles = Set<GachaProfileID>()
        try modelContext.transaction {
            let oldProfileMOs = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
            newProfiles = Set(oldProfileMOs.map(\.asSendable))
            var entryFetchDescriptor = FetchDescriptor<PZGachaEntryMO>()
            entryFetchDescriptor.propertiesToFetch = [\.uid, \.game]
            let filteredEntries = try modelContext.fetch(entryFetchDescriptor)
            filteredEntries.forEach { currentGachaEntry in
                let alreadyExisted = newProfiles.first { $0.uidWithGame == currentGachaEntry.uidWithGame }
                guard alreadyExisted == nil else { return }
                let newProfile = GachaProfileID(uid: currentGachaEntry.uid, game: currentGachaEntry.gameTyped)
                newProfiles.insert(newProfile)
            }
            oldProfileMOs.forEach {
                modelContext.delete($0)
            }
            newProfiles.forEach {
                modelContext.insert($0.asMO)
            }
        }
        return newProfiles.sorted { $0.uidWithGame < $1.uidWithGame }
    }
}
