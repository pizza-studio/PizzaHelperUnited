// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZBaseKit
@preconcurrency import Sworm

// MARK: - AccountMOSputnik

@MainActor
public final class AccountMOSputnik {
    // MARK: Lifecycle

    public init(persistence: DBPersistenceMethod, backgroundContext: Bool) throws {
        let pc4HSR = try AccountMO4HSR.getLoadedPersistentContainer(persistence: persistence)
        let pc4GI = try AccountMO4GI.getLoadedPersistentContainer(persistence: persistence)
        if backgroundContext {
            self.db4HSR = .init(managedObjectContext: pc4HSR.newBackgroundContext)
            self.db4GI = .init(managedObjectContext: pc4GI.newBackgroundContext)
        } else {
            self.db4HSR = .init { pc4HSR.viewContext }
            self.db4GI = .init { pc4GI.viewContext }
        }
    }

    // MARK: Public

    public static let shared = try! AccountMOSputnik(persistence: .cloud, backgroundContext: false)

    public func queryAccountDataMO(uuid givenUUID: String) throws -> PZProfileSendable? {
        var result: [(AccountMOProtocol, Pizza.SupportedGame)] = []
        try Pizza.SupportedGame.allCases.forEach { game in
            try theDB(for: game)?.perform { ctx in
                switch game {
                case .genshinImpact:
                    try ctx.fetch(AccountMO4GI.all).forEach {
                        let decoded = try $0.decode()
                        if decoded.uuid.uuidString == givenUUID {
                            result.append((decoded, .genshinImpact))
                        }
                    }
                case .starRail:
                    try ctx.fetch(AccountMO4HSR.all).forEach {
                        let decoded = try $0.decode()
                        if decoded.uuid.uuidString == givenUUID {
                            result.append((decoded, .starRail))
                        }
                    }
                case .zenlessZone: return
                }
            }
        }
        guard let firstResult = result.first else { return nil }
        let game = firstResult.1
        let oldProfileMO = firstResult.0
        let newMO = PZProfileMO.makeInheritedInstance(
            game: game, uid: oldProfileMO.uid, configuration: oldProfileMO
        )
        return newMO?.asSendable
    }

    public func allAccountDataMO(for game: Pizza.SupportedGame) throws -> [AccountMOProtocol] {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.fetch(AccountMO4GI.all).map { try $0.decode() }
            case .starRail: try ctx.fetch(AccountMO4HSR.all).map { try $0.decode() }
            case .zenlessZone: []
            }
        } ?? []
    }

    public func countAllAccountData(for game: Pizza.SupportedGame) throws -> Int {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.count(of: AccountMO4GI.all)
            case .starRail: try ctx.count(of: AccountMO4HSR.all)
            case .zenlessZone: 0
            }
        } ?? 0
    }

    public func countAllAccountData() throws -> Int {
        try countAllAccountData(for: .genshinImpact) + countAllAccountData(for: .starRail)
    }

    public func allAccountDataAsPZProfileSendable() throws -> [PZProfileSendable] {
        // Genshin.
        let genshinData: [PZProfileMO]? = try allAccountDataMO(for: .genshinImpact).compactMap { oldMO in
            let result = PZProfileMO.makeInheritedInstance(
                game: .genshinImpact, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        // StarRail.
        let hsrData: [PZProfileMO]? = try allAccountDataMO(for: .starRail).compactMap { oldMO in
            let result = PZProfileMO.makeInheritedInstance(
                game: .starRail, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        let dataSet: [PZProfileMO] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet.map(\.asSendable)
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
