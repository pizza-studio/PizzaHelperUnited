// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZCoreDataKitShared
@preconcurrency import Sworm

// MARK: - CDGachaMOActor

/// 警告：请务必不要直接初始化这个 class。请使用 .shared。
public actor CDGachaMOActor: Sendable {
    // MARK: Lifecycle

    public init(persistence: DBPersistenceMethod, backgroundContext: Bool) throws {
        let pc4HSR = try CDGachaMO4HSR.getLoadedPersistentContainer(persistence: persistence)
        let pc4GI = try CDGachaMO4GI.getLoadedPersistentContainer(persistence: persistence)
        if backgroundContext {
            self.db4HSR = .init(managedObjectContext: pc4HSR.newBackgroundContext)
            self.db4GI = .init(managedObjectContext: pc4GI.newBackgroundContext)
        } else {
            self.db4HSR = .init { pc4HSR.viewContext }
            self.db4GI = .init { pc4GI.viewContext }
        }
    }

    // MARK: Public

    public static let shared = try! CDGachaMOActor(persistence: .cloud, backgroundContext: true)

    public func confirmWhetherHavingData() async -> Bool {
        ((try? await countAllDataEntries()) ?? 0) > 0
    }

    public func countAllDataEntries(for game: PZCoreDataKit.CDStoredGame) throws -> Int {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.count(of: CDGachaMO4GI.all)
            case .starRail: try ctx.count(of: CDGachaMO4HSR.all)
            }
        } ?? 0
    }

    public func countAllDataEntries() async throws -> Int {
        async let countGI = countAllDataEntries(for: .genshinImpact)
        async let countHSR = countAllDataEntries(for: .starRail)
        let intGI = try await countGI
        let intHSR = try await countHSR
        return intGI + intHSR
    }

    /// Refugee API.
    ///
    /// WARNING: This does not fix Genshin Gacha Entry ItemIDs.
    public func getAllGenshinDataEntriesVanilla() throws
        -> [CDGachaMO4GI] {
        try theDB(for: .genshinImpact)?.perform { ctx in
            try ctx.fetch(CDGachaMO4GI.all).map { try $0.decode() }
        } ?? []
    }

    /// WARNING: This does not fix Genshin Gacha Entry ItemIDs.
    public func getAllDataEntriesVanilla(
        for game: PZCoreDataKit.CDStoredGame,
        genshinGachaEntryFixHandler: @escaping (inout [CDGachaMO4GI]) throws -> Void
    ) throws
        -> [CDGachaMOProtocol] {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact:
                var genshinDataRAW = try ctx.fetch(CDGachaMO4GI.all).map { try $0.decode() }
                try genshinGachaEntryFixHandler(&genshinDataRAW)
                return genshinDataRAW
            case .starRail: return try ctx.fetch(CDGachaMO4HSR.all).map { try $0.decode() }
            }
        } ?? []
    }

    // MARK: Internal

    func theDB(for game: PZCoreDataKit.CDStoredGame) -> PersistentContainer? {
        switch game {
        case .genshinImpact: db4GI
        case .starRail: db4HSR
        }
    }

    // MARK: Private

    private let db4GI: PersistentContainer
    private let db4HSR: PersistentContainer
}
