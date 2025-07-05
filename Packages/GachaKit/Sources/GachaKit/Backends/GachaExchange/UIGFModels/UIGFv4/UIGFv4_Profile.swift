// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import GachaMetaDB
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4 {
    public typealias ProfileHSR = Profile<GachaItemHSR>
    public typealias ProfileGI = Profile<GachaItemGI>
    public typealias ProfileZZZ = Profile<GachaItemZZZ>

    public struct Profile<ItemType: UIGFGachaItemProtocol>: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(lang: GachaLanguage, list: [ItemType], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([ItemType].self, forKey: .list)
            self.lang = try container.decodeIfPresent(GachaLanguage.self, forKey: .lang)
            self.timezone = try container.decode(Int.self, forKey: .timezone)

            if let x = try? container.decode(String.self, forKey: .uid), !x.isEmpty {
                self.uid = x
            } else if let x = try? container.decode(Int.self, forKey: .uid) {
                self.uid = x.description
            } else {
                throw DecodingError.typeMismatch(
                    String.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Type for UID shall be either String or Integer."
                    )
                )
            }

            if ItemType.self == GachaItemGI.self {
                /// Check whether GachaItemDB is expired.
                if GachaMeta.sharedDB.mainDB4GI.checkIfExpired(against: Set<String>(list.map(\.itemID))) {
                    defer {
                        Task { @MainActor in
                            try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                        }
                    }
                    throw GachaMeta.GMDBError.databaseExpired(game: ItemType.game)
                }
            }
        }

        // MARK: Public

        /// 语言代码
        public var lang: GachaLanguage?
        public var list: [ItemType]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String

        /// 对应的游戏
        public var game: Pizza.SupportedGame { ItemType.game }

        /// 对应的 GachaProfileID
        public var gachaProfileID: GachaProfileID { .init(uid: uid, game: game) }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4 {
    func extractGachaProfileIDs() -> [GachaProfileID] {
        var results = Set<GachaProfileID>()
        giProfiles?.forEach { profile in
            results.insert(profile.gachaProfileID)
        }
        hsrProfiles?.forEach { profile in
            results.insert(profile.gachaProfileID)
        }
        zzzProfiles?.forEach { profile in
            results.insert(profile.gachaProfileID)
        }
        return results.sorted { $0.uidWithGame < $1.uidWithGame }
    }
}
