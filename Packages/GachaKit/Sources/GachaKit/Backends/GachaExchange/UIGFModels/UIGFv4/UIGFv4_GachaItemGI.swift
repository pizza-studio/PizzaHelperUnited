// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import GachaMetaDB
import PZBaseKit

// MARK: - UIGFv4.GachaItemGI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4 {
    public struct GachaItemGI: UIGFGachaItemProtocol {
        // MARK: Lifecycle

        public init(
            count: String?,
            gachaID: String?,
            gachaType: PoolType,
            id: String,
            itemID: String,
            itemType: String?,
            name: String?,
            rankType: String?,
            time: String
        ) {
            self.count = count
            self.gachaID = gachaID ?? "0"
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

            self.gachaType = try container.decode(GachaTypeGI.self, forKey: .gachaType)

            self.id = try container.decode(String.self, forKey: .id)
            if Int(id) == nil { error = UIGFv4.makeDecodingError(CodingKeys.id) }

            self.itemID = try container.decode(String.self, forKey: .itemID)
            if !itemID.isInt { error = UIGFv4.makeDecodingError(CodingKeys.itemID) }

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

            self.gachaID = "0"

            if let error = error { throw error }
        }

        // MARK: Public

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
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

        public typealias PoolType = GachaTypeGI

        public static var game: Pizza.SupportedGame { .genshinImpact }

        /// 物品个数，一般为1，API返回
        public var count: String?
        /// 卡池 Id
        public var gachaID: String
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
        public var uigfGachaType: GachaTypeGI.UIGFGachaType { gachaType.uigfGachaType }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(count, forKey: .count)
            try container.encode(gachaType, forKey: .gachaType)
            try container.encode(uigfGachaType, forKey: .uigfGachaType)
            try container.encode(id, forKey: .id)
            try container.encode(itemID, forKey: .itemID)
            try container.encodeIfPresent(itemType, forKey: .itemType)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(rankType, forKey: .rankType)
            try container.encode(time, forKey: .time)
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension UIGFv4.GachaItemGI {
    public mutating func editId(_ newId: String) {
        id = newId
    }
}
