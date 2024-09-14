// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZBaseKit

extension GachaFetchModels.PageFetched.FetchedEntry {
    func toGachaEntryMO(game: Pizza.SupportedGame, fixItemIDs: Bool = true) async throws -> PZGachaEntryMO {
        let result = PZGachaEntryMO { newEntry in
            newEntry.game = game
            newEntry.uid = uid
            newEntry.count = count
            newEntry.gachaID = gachaID
            newEntry.gachaType = gachaType
            newEntry.id = id
            newEntry.itemID = itemID
            newEntry.itemType = itemType
            newEntry.lang = lang
            newEntry.name = name
            newEntry.rankType = rankType
            newEntry.time = time
        }

        if fixItemIDs, game == .genshinImpact, itemID.isEmpty {
            var newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            if newItemID == nil {
                try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            }
            guard let newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name) else {
                throw GachaMeta.GMDBError.databaseExpired
            }
            result.itemID = newItemID.description
        }

        return result
    }
}

// MARK: - APIs for converting GachaEntryMO to UIGF.

extension PZGachaEntryMO {
    public func fixItemID() async throws {
        if game == .genshinImpact, itemID.isEmpty {
            var newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            if newItemID == nil {
                try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            }
            guard let newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name) else {
                throw GachaMeta.GMDBError.databaseExpired
            }
            itemID = newItemID.description
        }
    }

    public func toUIGFGachaEntryWithFix(for game: Pizza.SupportedGame) async throws -> any UIGFGachaItemProtocol {
        try await fixItemID()
        return try toUIGFGachaEntry(for: game)
    }

    public func toUIGFGachaEntry(for game: Pizza.SupportedGame) throws -> any UIGFGachaItemProtocol {
        switch game {
        case .genshinImpact:
            guard Int(gachaID) != nil else {
                throw GachaMeta.GMDBError.itemIDInvalid(name: name, game: .genshinImpact)
            }
            return UIGFv4.GachaItemGI(
                count: count,
                gachaID: gachaID,
                gachaType: .init(rawValue: gachaType),
                id: id,
                itemID: itemID,
                itemType: itemType,
                name: name,
                rankType: rankType,
                time: time
            )
        case .starRail:
            return UIGFv4.GachaItemHSR(
                count: count,
                gachaID: gachaID,
                gachaType: .init(rawValue: gachaType),
                id: id,
                itemID: itemID,
                itemType: itemType,
                name: name,
                rankType: rankType,
                time: time
            )
        case .zenlessZone:
            return UIGFv4.GachaItemZZZ(
                count: count,
                gachaID: gachaID,
                gachaType: .init(rawValue: gachaType),
                id: id,
                itemID: itemID,
                itemType: itemType,
                name: name,
                rankType: rankType,
                time: time
            )
        }
    }
}

extension [PZGachaEntryMO] {
    func extractItem<T: UIGFGachaItemProtocol>(_ type: T.Type) throws -> [(uid: String, entry: T)] {
        try self.compactMap {
            if let matched = try $0.toUIGFGachaEntry(for: T.game) as? T {
                return (uid: $0.uid, entry: matched)
            }
            return nil
        }
    }

    func extractProfiles<T: UIGFGachaItemProtocol>(
        _ type: T.Type,
        lang: GachaLanguage = .current
    ) throws
        -> [UIGFv4.Profile<T>] {
        let mapped: [String: [(uid: String, entry: T)]] = Dictionary(grouping: try extractItem(T.self)) { $0.uid }
        var profiles = [UIGFv4.Profile<T>]()
        try mapped.forEach { uid, setData in
            var list: [T] = setData.map(\.entry)
            try list.updateLanguage(lang)
            profiles.append(
                .init(
                    lang: lang,
                    list: list,
                    timezone: GachaKit.getServerTimeZoneDelta(uid: uid, game: T.game),
                    uid: uid
                )
            )
        }
        return profiles
    }
}
