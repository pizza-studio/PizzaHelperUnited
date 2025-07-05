// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZBaseKit

// MARK: - APIs for converting fetched contents to PZGachaEntrySendable.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaFetchModels.PageFetched.FetchedEntry {
    func toGachaEntrySendable(game: Pizza.SupportedGame, fixItemIDs: Bool = true) async throws -> PZGachaEntrySendable {
        var result = PZGachaEntrySendable { newEntry in
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

        if fixItemIDs, game == .genshinImpact, itemID.isNotInt {
            var newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            if newItemID == nil {
                try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
            }
            guard let newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name) else {
                throw GachaMeta.GMDBError.databaseExpired(game: game)
            }
            result.itemID = newItemID.description
        }

        return result
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaFetchModels.PageFetched {
    func extractEntries(
        game: Pizza.SupportedGame,
        fixItemIDs: Bool = true,
        itemCounter: inout Int?
    ) async throws
        -> [PZGachaEntrySendable] {
        var result = [PZGachaEntrySendable]()
        for rawEntry in list {
            let converted = try await rawEntry.toGachaEntrySendable(game: game, fixItemIDs: fixItemIDs)
            result.append(converted)
            if itemCounter != nil { itemCounter = (itemCounter ?? 0) + 1 }
        }
        return result
    }
}

// MARK: - APIs for converting PZGachaEntryProtocol to UIGF.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension PZGachaEntryProtocol {
    public mutating func fixItemID() async throws {
        guard Pizza.SupportedGame(rawValue: game) == .genshinImpact, itemID.isNotInt else { return }
        var newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
        if newItemID == nil {
            try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
            newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
        }
        guard let newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name) else {
            throw GachaMeta.GMDBError.databaseExpired(game: gameTyped)
        }
        itemID = newItemID.description
    }

    public func asItemIDFixed() async throws -> Self {
        guard Pizza.SupportedGame(rawValue: game) == .genshinImpact else { return self }
        guard itemID.isNotInt else { return self }
        var result = self
        var newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
        if newItemID == nil {
            try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
            newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name)
        }
        guard let newItemID = GachaMeta.sharedDB.reverseQuery4GI(for: name) else {
            throw GachaMeta.GMDBError.databaseExpired(game: gameTyped)
        }
        result.itemID = newItemID.description
        return result
    }

    public func toUIGFGachaEntryWithFix(
        for game: Pizza.SupportedGame
    ) async throws
        -> any UIGFGachaItemProtocol {
        try await asItemIDFixed().toUIGFGachaEntry(for: game)
    }

    public func toUIGFGachaEntry(for game: Pizza.SupportedGame) throws -> any UIGFGachaItemProtocol {
        switch game {
        case .genshinImpact:
            guard Int(gachaID) != nil else {
                throw GachaMeta.GMDBError.itemIDInvalid(
                    name: name, game: .genshinImpact, uid: uid
                )
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension [PZGachaEntryProtocol] {
    func extractItem<T: UIGFGachaItemProtocol>(_ type: T.Type) throws -> [(gpid: GachaProfileID, entry: T)] {
        try compactMap {
            if let matched = try $0.toUIGFGachaEntry(for: $0.gameTyped) as? T {
                return (gpid: GachaProfileID(uid: $0.uid, game: $0.gameTyped), entry: matched)
            }
            return nil
        }
    }

    func extractProfiles<T: UIGFGachaItemProtocol>(
        _ type: T.Type,
        lang: GachaLanguage = .current
    ) throws
        -> [UIGFv4.Profile<T>]? {
        let mapped: [GachaProfileID: [(gpid: GachaProfileID, entry: T)]] =
            Dictionary(grouping: try extractItem(T.self)) { $0.gpid }
        var profiles = [UIGFv4.Profile<T>]()
        // 筛掉不受游戏支持的语言。
        let lang = lang.sanitized(by: T.game)
        try mapped.forEach { gpid, setData in
            guard gpid.game == T.game else { return }
            var list: [T] = setData.map(\.entry)
            try list.updateLanguage(lang)
            profiles.append(
                .init(
                    lang: lang,
                    list: list,
                    timezone: GachaKit.getServerTimeZoneDelta(uid: gpid.uid, game: T.game),
                    uid: gpid.uid
                )
            )
        }
        return profiles.isEmpty ? nil : profiles
    }
}

// MARK: - APIs for converting UIGF to PZGachaEntrySendable.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFGachaItemProtocol {
    func asPZGachaEntrySendable(uid: String) -> PZGachaEntrySendable {
        let result = PZGachaEntrySendable { newEntry in
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4.Profile {
    func extractEntries() -> [PZGachaEntrySendable] {
        list.map { $0.asPZGachaEntrySendable(uid: self.uid) }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4 {
    func extractAllEntries() -> [PZGachaEntrySendable] {
        var result = [[PZGachaEntrySendable]]()
        result.append(contentsOf: giProfiles?.map { $0.extractEntries() } ?? [])
        result.append(contentsOf: hsrProfiles?.map { $0.extractEntries() } ?? [])
        result.append(contentsOf: zzzProfiles?.map { $0.extractEntries() } ?? [])
        return result.reduce([], +)
    }
}
