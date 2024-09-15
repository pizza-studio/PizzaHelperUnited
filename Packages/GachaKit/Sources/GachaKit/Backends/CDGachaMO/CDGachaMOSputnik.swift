// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaMetaDB
import PZAccountKit
import PZBaseKit
@preconcurrency import Sworm

// MARK: - CDGachaMOSputnik

@MainActor
public final class CDGachaMOSputnik {
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

    public static let shared = try! CDGachaMOSputnik(persistence: .cloud, backgroundContext: false)

    public var hasData: Bool {
        ((try? countAllCDGachaMOAsPZGachaEntryMO()) ?? 0) > 0
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

    public func countAllCDGachaMOAsPZGachaEntryMO() throws -> Int {
        try countAllCDGachaMO(for: .genshinImpact) + countAllCDGachaMO(for: .starRail)
    }

    public func allCDGachaMOAsPZGachaEntryMO() throws -> [PZGachaEntryMO] {
        // Genshin.
        let genshinData: [PZGachaEntryMO]? = try allGachaDataMO(for: .genshinImpact).map(\.asPZGachaEntryMO)
        // Fix Genshin ItemIDs.
        let problematicObjects: [PZGachaEntryMO]? = genshinData?.filter { Int($0.itemID) == nil }
        let revDB = GachaMeta.sharedDB.mainDB4GI.generateHotReverseQueryDict(for: HoYo.APILang.langCHS.rawValue) ?? [:]
        try problematicObjects?.forEach { obj in
            if let newItemIDInt = revDB[obj.name] {
                obj.itemID = newItemIDInt.description
            } else {
                Task { @MainActor in
                    try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                }
                throw GachaMeta.GMDBError.databaseExpired
            }
        }

        // StarRail.
        let hsrData: [PZGachaEntryMO]? = try allGachaDataMO(for: .starRail).map(\.asPZGachaEntryMO)
        let dataSet: [PZGachaEntryMO] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
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

    private var db4GI: PersistentContainer
    private var db4HSR: PersistentContainer
}
