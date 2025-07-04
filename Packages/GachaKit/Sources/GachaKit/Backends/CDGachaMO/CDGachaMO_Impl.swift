// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZCoreDataKit4GachaEntries
import PZCoreDataKitShared

extension CDGachaMOSputnik {
    public func getAllDataEntriesAsSendable() throws -> [PZGachaEntrySendable] {
        // Genshin.
        let genshinData = try getAllDataEntriesAsSendable(for: .genshinImpact, fixItemIDs: true)
        // StarRail.
        let hsrData = try getAllDataEntriesAsSendable(for: .starRail)
        let dataSet: [PZGachaEntrySendable] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet
    }

    public func getAllDataEntriesAsSendable(
        for game: PZCoreDataKit.StoredGame,
        fixItemIDs: Bool = true
    ) throws
        -> [PZGachaEntrySendable] {
        let processed = try getAllDataEntries(for: game, fixItemIDs: fixItemIDs)
        return processed.compactMap { object in
            (object as? GachaSendableConvertible)?.asPZGachaEntrySendable
        }
    }

    public func getAllDataEntries(
        for game: PZCoreDataKit.StoredGame,
        fixItemIDs: Bool = true
    ) throws
        -> [CDGachaMOProtocol] {
        try getAllDataEntriesVanilla(for: game) { genshinDataRAW in
            if fixItemIDs {
                // Fix Genshin ItemIDs.
                genshinDataRAW.fixItemIDs()
                if genshinDataRAW.mightHaveNonCHSLanguageTag {
                    try genshinDataRAW.updateLanguage(.langCHS)
                }
                for idx in 0 ..< genshinDataRAW.count {
                    let currentObj = genshinDataRAW[idx]
                    guard Int(currentObj.itemId) == nil else { continue }
                    Task { @MainActor in
                        try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                    }
                    throw GachaMeta.GMDBError.databaseExpired(game: .genshinImpact)
                }
            }
        }
    }
}

// MARK: - GachaSendableConvertible

public protocol GachaSendableConvertible {
    var asPZGachaEntrySendable: PZGachaEntrySendable { get }
}

// MARK: - CDGachaMO4GI + GachaSendableConvertible

extension CDGachaMO4GI: GachaSendableConvertible {
    public var asPZGachaEntrySendable: PZGachaEntrySendable {
        PZGachaEntrySendable.init { newEntry in
            newEntry.game = PZCoreDataKit.StoredGame.genshinImpact.rawValue
            newEntry.uid = uid
            newEntry.count = 1.description
            newEntry.gachaType = gachaType.description
            newEntry.id = id
            newEntry.itemID = itemId
            newEntry.itemType = itemType
            newEntry.lang = lang
            newEntry.name = name
            newEntry.rankType = rankType.description
            newEntry.time = time.asUIGFDate(
                timeZoneDelta: GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact)
            )
        }
    }
}

// MARK: - CDGachaMO4HSR + GachaSendableConvertible

extension CDGachaMO4HSR: GachaSendableConvertible {
    public var asPZGachaEntrySendable: PZGachaEntrySendable {
        PZGachaEntrySendable.init { newEntry in
            newEntry.game = PZCoreDataKit.StoredGame.starRail.rawValue
            newEntry.uid = uid
            newEntry.count = count.description
            newEntry.gachaID = gachaID.description
            newEntry.gachaType = gachaTypeRawValue
            newEntry.id = id
            newEntry.itemID = itemID
            newEntry.itemType = itemTypeRawValue
            newEntry.lang = langRawValue
            newEntry.name = name
            newEntry.rankType = rankRawValue
            newEntry.time = timeRawValue ?? time.asUIGFDate(
                timeZoneDelta: GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact)
            )
        }
    }
}
