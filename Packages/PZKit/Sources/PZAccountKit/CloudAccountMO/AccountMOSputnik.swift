// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import PZBaseKit
import Sworm

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

    public func allAccountDataMO(for game: Pizza.SupportedGame) throws -> [AccountMOProtocol] {
        try theDB(for: game).perform { ctx in
            switch game {
            case .genshinImpact:
                try ctx.fetch(AccountMO4GI.all).map {
                    try $0.decode()
                }
            case .starRail:
                try ctx.fetch(AccountMO4HSR.all).map {
                    try $0.decode()
                }
            }
        }
    }

    // MARK: Internal

    static let shared = try? AccountMOSputnik(persistence: .cloud, backgroundContext: false)

    func theDB(for game: Pizza.SupportedGame) -> PersistentContainer {
        switch game {
        case .genshinImpact: db4GI
        case .starRail: db4HSR
        }
    }

    // MARK: Private

    private var db4GI: PersistentContainer
    private var db4HSR: PersistentContainer
}
