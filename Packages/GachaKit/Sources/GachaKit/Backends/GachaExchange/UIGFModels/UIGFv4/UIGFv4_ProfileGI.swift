// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - UIGFv4.ProfileGI

extension UIGFv4 {
    public struct ProfileGI: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: GachaLanguage, list: [GachaItemGI], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([GachaItemGI].self, forKey: .list)
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

            /// Check whether GachaItemDB is expired.
            if GachaMetaDBExposed.shared.mainDB4GI.checkIfExpired(against: Set<String>(list.map(\.itemID))) {
                defer {
                    Task { @MainActor in
                        try? await GachaMetaDBExposed.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                    }
                }
                throw GachaMetaDBExposed.GMDBError.databaseExpired
            }
        }

        // MARK: Public

        public struct GachaItemGI: Codable, Hashable, Sendable {
            // MARK: Lifecycle

            public init(
                count: String?,
                gachaType: GachaTypeGI,
                id: String,
                itemID: String,
                itemType: String?,
                name: String?,
                rankType: String?,
                time: String,
                uigfGachaType: GachaTypeGI.UIGFGachaType
            ) {
                self.count = count
                self.gachaType = gachaType
                self.id = id
                self.itemID = itemID
                self.itemType = itemType
                self.name = name
                self.rankType = rankType
                self.time = time
                self.uigfGachaType = uigfGachaType
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var error: Error?

                self.count = try container.decodeIfPresent(String.self, forKey: .count)
                if Int(count ?? "1") == nil { error = UIGFv4.makeDecodingError(CodingKeys.count) }

                self.gachaType = try container.decode(GachaTypeGI.self, forKey: .gachaType)

                self.id = try container.decode(String.self, forKey: .id)
                if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

                self.itemID = try container.decode(String.self, forKey: .itemID)
                if Int(itemID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

                self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
                if itemType?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.itemType) }

                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                if name?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.name) }

                self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
                if Int(rankType ?? "3") == nil { error = UIGFv4.makeDecodingError(CodingKeys.rankType) }

                self.time = try container.decode(String.self, forKey: .time)
                if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                    error = UIGFv4.makeDecodingError(CodingKeys.time)
                }

                self.uigfGachaType = try container
                    .decode(GachaTypeGI.UIGFGachaType.self, forKey: .uigfGachaType)

                if let error = error { throw error }
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case count
                case gachaType = "gacha_type"
                case id
                case itemID = "item_id"
                case itemType = "item_type"
                case name
                case rankType = "rank_type"
                case time
                case uigfGachaType = "uigf_gacha_type"
            }

            /// 物品个数，一般为1，API返回
            public var count: String?
            /// 卡池类型，API返回
            public var gachaType: GachaTypeGI
            /// 记录内部 ID, API返回
            public var id: String
            /// 物品的内部 ID
            public var itemID: String
            /// 物品类型, API返回
            public var itemType: String?
            /// 物品名称, API返回
            public var name: String?
            /// 物品等级, API返回
            public var rankType: String?
            /// 获取物品的本地时间，与 timezone 一起计算出物品的准确获取时间，API返回
            public var time: String
            /// UIGF 卡池类型，用于区分卡池类型不同，但卡池保底计算相同的物品
            public var uigfGachaType: GachaTypeGI.UIGFGachaType
        }

        /// 语言代码
        public var lang: GachaLanguage?
        public var list: [GachaItemGI]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String
    }
}

extension UIGFv4.ProfileGI.GachaItemGI {
    public mutating func editId(_ newId: String) {
        id = newId
    }
}

extension [UIGFv4.ProfileGI.GachaItemGI] {
    /// 将当前 UIGFGachaItem 的物品分类与名称转换成给定的语言。
    /// - Parameter lang: 给定的语言。
    mutating func updateLanguage(_ lang: GachaLanguage) {
        var newItemContainer = Self()
        // 君子协定：这里要求 UIGFGachaItem 的 itemID 必须是有效值，否则会出现灾难性的后果。
        self.forEach { currentItem in
            let theDB = GachaMetaDBExposed.shared.mainDB4GI
            var newItem = currentItem
            let itemTypeRaw: GachaItemType = .init(itemID: newItem.itemID, game: .genshinImpact)
            newItem.itemType = itemTypeRaw.getTranslatedRaw(for: lang, game: .genshinImpact)
            if let newName = theDB.plainQueryForNames(itemID: newItem.itemID, langID: lang.rawValue) {
                newItem.name = newName
            }
            newItemContainer.append(newItem)
        }
        self = newItemContainer
    }
}
