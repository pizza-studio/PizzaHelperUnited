// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaMetaDB
import PZAccountKit
import PZBaseKit
@preconcurrency import Sworm

// MARK: - CDGachaMOSputnik

/// 警告：请务必不要直接初始化这个 class。请借由 GachaActor 来使用这个 class。
public final class CDGachaMOSputnik: Sendable {
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

    public func confirmWhetherHavingData() async -> Bool {
        ((try? await countAllCDGachaMOAsPZGachaEntryMO()) ?? 0) > 0
    }

    public func allGachaDataMO(for game: Pizza.SupportedGame) throws -> [CDGachaMOProtocol] {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.fetch(CDGachaMO4GI.all).map { try $0.decode() }
            case .starRail: try ctx.fetch(CDGachaMO4HSR.all).map { try $0.decode() }
            case .zenlessZone: []
            }
        } ?? []
    }

    public func countAllCDGachaMO(for game: Pizza.SupportedGame) throws -> Int {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.count(of: CDGachaMO4GI.all)
            case .starRail: try ctx.count(of: CDGachaMO4HSR.all)
            case .zenlessZone: 0
            }
        } ?? 0
    }

    public func countAllCDGachaMOAsPZGachaEntryMO() async throws -> Int {
        async let countGI = countAllCDGachaMO(for: .genshinImpact)
        async let countHSR = countAllCDGachaMO(for: .starRail)
        let intGI = try await countGI
        let intHSR = try await countHSR
        return intGI + intHSR
    }

    public func allCDGachaMOAsPZGachaEntryMO() throws -> [PZGachaEntrySendable] {
        // Genshin.
        var genshinData: [PZGachaEntrySendable] = try allGachaDataMO(for: .genshinImpact).map(\.asPZGachaEntrySendable)
        // Fix Genshin ItemIDs.
        let revDB = GachaMeta.sharedDB.mainDB4GI.generateHotReverseQueryDict(for: HoYo.APILang.langCHS.rawValue) ?? [:]
        for idx in 0 ..< genshinData.count {
            let currentObj = genshinData[idx]
            guard Int(currentObj.itemID) == nil else { continue }
            if let newItemIDInt = revDB[currentObj.name] {
                genshinData[idx].itemID = newItemIDInt.description
            } else {
                Task { @MainActor in
                    try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                }
                throw GachaMeta.GMDBError.databaseExpired(game: .genshinImpact)
            }
        }
        // StarRail.
        let hsrData: [PZGachaEntrySendable]? = try allGachaDataMO(for: .starRail).map(\.asPZGachaEntrySendable)
        let dataSet: [PZGachaEntrySendable] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet
    }

    // MARK: Internal

    func theDB(for game: Pizza.SupportedGame) -> PersistentContainer? {
        switch game {
        case .genshinImpact: db4GI
        case .starRail: db4HSR
        case .zenlessZone: nil
        }
    }

    // MARK: Private

    private let db4GI: PersistentContainer
    private let db4HSR: PersistentContainer
}
