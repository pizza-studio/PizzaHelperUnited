// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZCoreDataKitShared
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

    public func queryAccountData(uuid givenUUID: String) throws -> (
        any AccountMOProtocol
    )? {
        var result: [AccountMOProtocol] = []
        try PZCoreDataKit.StoredGame.allCases.forEach { game in
            try theDB(for: game)?.perform { ctx in
                switch game {
                case .genshinImpact:
                    try ctx.fetch(AccountMO4GI.all).forEach {
                        let decoded = try $0.decode()
                        if decoded.uuid.uuidString == givenUUID {
                            result.append(decoded)
                        }
                    }
                case .starRail:
                    try ctx.fetch(AccountMO4HSR.all).forEach {
                        let decoded = try $0.decode()
                        if decoded.uuid.uuidString == givenUUID {
                            result.append(decoded)
                        }
                    }
                }
            }
        }
        guard let firstResult = result.first else { return nil }
        return firstResult
    }

    /// Refugee API.
    public func allAccountDataForGenshin() throws -> [AccountMO4GI] {
        try theDB(for: .genshinImpact)?.perform { ctx in
            try ctx.fetch(AccountMO4GI.all).map {
                try $0.decode()
            }
        } ?? []
    }

    public func allAccountData(
        for game: PZCoreDataKit.StoredGame
    ) throws
        -> [AccountMOProtocol] {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.fetch(AccountMO4GI.all).map {
                    let obj = try $0.decode()
                    return obj
                }
            case .starRail: try ctx.fetch(AccountMO4HSR.all).map {
                    let obj = try $0.decode()
                    return obj
                }
            }
        } ?? []
    }

    public func countAllAccountData(for game: PZCoreDataKit.StoredGame) throws -> Int {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.count(of: AccountMO4GI.all)
            case .starRail: try ctx.count(of: AccountMO4HSR.all)
            }
        } ?? 0
    }

    public func countAllAccountData() throws -> Int {
        try countAllAccountData(for: .genshinImpact) + countAllAccountData(for: .starRail)
    }

    // MARK: Internal

    func theDB(for game: PZCoreDataKit.StoredGame) -> PersistentContainer? {
        switch game {
        case .genshinImpact: db4GI
        case .starRail: db4HSR
        }
    }

    // MARK: Private

    private var db4GI: PersistentContainer
    private var db4HSR: PersistentContainer
}
