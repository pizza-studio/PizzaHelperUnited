// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: UIGFv4.ProfileHSR

extension UIGFv4 {
    public struct ProfileHSR: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(lang: GachaLanguage, list: [GachaItemHSR], timezone: Int?, uid: String) {
            self.lang = lang
            self.list = list
            self.timezone = timezone ?? GachaKit.getServerTimeZoneDelta(uid: uid, game: .starRail)
            self.uid = uid
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.list = try container.decode([GachaItemHSR].self, forKey: .list)
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
        }

        // MARK: Public

        public struct GachaItemHSR: Codable, Hashable, Sendable {
            // MARK: Lifecycle

            public init(
                count: String?,
                gachaID: String,
                gachaType: GachaTypeHSR,
                id: String,
                itemID: String,
                itemType: String?,
                name: String?,
                rankType: String?,
                time: String
            ) {
                self.count = count
                self.gachaID = gachaID
                self.gachaType = gachaType
                self.id = id
                self.itemID = itemID
                self.itemType = itemType
                self.name = name
                self.rankType = rankType
                self.time = time
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var error: Error?

                self.count = try container.decodeIfPresent(String.self, forKey: .count)
                if Int(count ?? "1") == nil { error = UIGFv4.makeDecodingError(CodingKeys.count) }

                self.gachaType = try container.decode(GachaTypeHSR.self, forKey: .gachaType)

                self.id = try container.decode(String.self, forKey: .id)
                if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

                self.itemID = try container.decode(String.self, forKey: .itemID)
                if Int(itemID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

                self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
                if itemType?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.itemType) }

                self.gachaID = try container.decode(String.self, forKey: .gachaID)
                if Int(gachaID) == nil { error = UIGFv4.makeDecodingError(CodingKeys.gachaID) }

                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                if name?.isEmpty ?? false { error = UIGFv4.makeDecodingError(CodingKeys.name) }

                self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
                if Int(rankType ?? "3") == nil { error = UIGFv4.makeDecodingError(CodingKeys.rankType) }

                self.time = try container.decode(String.self, forKey: .time)
                if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                    error = UIGFv4.makeDecodingError(CodingKeys.time)
                }

                if let error = error { throw error }
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case count
                case gachaID = "gacha_id"
                case gachaType = "gacha_type"
                case id
                case itemID = "item_id"
                case itemType = "item_type"
                case name
                case rankType = "rank_type"
                case time
            }

            /// 物品个数，一般为1，API返回
            public var count: String?
            /// 卡池 Id
            public var gachaID: String
            /// 卡池类型
            public var gachaType: GachaTypeHSR
            /// 内部 Id
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
        }

        /// 语言代码
        public var lang: GachaLanguage?
        public var list: [GachaItemHSR]
        /// 时区偏移
        public var timezone: Int
        /// UID
        public var uid: String
    }
}
