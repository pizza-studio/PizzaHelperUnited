// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZBaseKit

// MARK: - APIs for converting fetched contents to GachaEntryMO.

extension GachaFetchModels.PageFetched.FetchedEntry {
    func toGachaEntryMO(game: Pizza.SupportedGame, fixItemIDs: Bool = true) async throws -> PZGachaEntryMO {
        let result = PZGachaEntryMO { newEntry in
            newEntry.game = game.rawValue
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

extension GachaFetchModels.PageFetched {
    func extractEntries(
        game: Pizza.SupportedGame,
        fixItemIDs: Bool = true,
        itemCounter: inout Int?
    ) async throws
        -> [PZGachaEntryMO] {
        var result = [PZGachaEntryMO]()
        for rawEntry in list {
            let converted = try await rawEntry.toGachaEntryMO(game: game, fixItemIDs: fixItemIDs)
            result.append(converted)
            if itemCounter != nil { itemCounter = (itemCounter ?? 0) + 1 }
        }
        return result
    }
}

// MARK: - APIs for converting GachaEntryMO to UIGF.

extension PZGachaEntryMO {
    public func fixItemID() async throws {
        if Pizza.SupportedGame(rawValue: game) == .genshinImpact, itemID.isEmpty {
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
        try compactMap {
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

// MARK: - APIs for converting UIGF to GachaEntryMO.

extension UIGFGachaItemProtocol {
    func asPZGachaEntryMO(uid: String) -> PZGachaEntryMO {
        let result = PZGachaEntryMO { newEntry in
            newEntry.game = game.rawValue
            newEntry.uid = uid
            newEntry.count = count ?? "1"
            newEntry.gachaID = gachaID
            newEntry.gachaType = gachaType.rawValue
            newEntry.id = id
            newEntry.itemID = itemID
            newEntry.itemType = GachaItemType(itemID: itemID, game: game).getTranslatedRaw(for: .langCHS, game: game)
            newEntry.lang = GachaLanguage.langCHS.rawValue
            newEntry.name = name ?? itemID
            let fallbackRankType: String = game == .zenlessZone ? "2" : "3"
            let newRankType = rankType ?? GachaItemRankType(itemID: itemID, game: game)?.uigfRankType(game: game)
            newEntry.rankType = newRankType ?? fallbackRankType
            newEntry.time = time
        }
        return result
    }
}

extension UIGFv4.Profile {
    func extractEntries() -> [PZGachaEntryMO] {
        list.map { $0.asPZGachaEntryMO(uid: self.uid) }
    }
}

extension UIGFv4 {
    func extractAllEntries() -> [PZGachaEntryMO] {
        var result = [[PZGachaEntryMO]]()
        result.append(contentsOf: giProfiles?.map { $0.extractEntries() } ?? [])
        result.append(contentsOf: hsrProfiles?.map { $0.extractEntries() } ?? [])
        result.append(contentsOf: zzzProfiles?.map { $0.extractEntries() } ?? [])
        return result.reduce([], +)
    }
}
