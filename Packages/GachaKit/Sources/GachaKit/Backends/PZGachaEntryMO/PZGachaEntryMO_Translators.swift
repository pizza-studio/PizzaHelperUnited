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
