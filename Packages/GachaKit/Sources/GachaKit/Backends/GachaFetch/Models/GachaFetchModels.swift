// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - GachaFetchModelTypeProtocol

protocol GachaFetchModelTypeProtocol: Decodable, Hashable, Equatable, Sendable {}

// MARK: - GachaFetchModels

/// Namespaces holding all types used for decoding raw remote JSON data of Gacha Records from HoYo servers.
///
/// This namespaces is intensionally made non-public.
@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public enum GachaFetchModels {}

// MARK: - GachaFetchModelError

/// This, as an exception, is public.
@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public enum GachaFetchModelError: Error, LocalizedError {
    case retrievalFailure(retCode: Int, message: String)

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case let .retrievalFailure(retCode, message):
            "GachaFetchModels page retrieval error. RetCode: \(retCode), Message: \(message)"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
}

// MARK: - GachaFetchModels.PageFetched

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaFetchModels {
    /// 专门用来解码伺服器远端抽卡记录的单页资料结构，共用于绝区零、原神、星穹铁道的抽卡记录。
    @available(iOS 17.0, *)
    @available(macCatalyst 17.0, *)
    @available(macOS 14.0, *)
    public struct PageFetched: GachaFetchModelTypeProtocol, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.page = try container.decode(String.self, forKey: .page)
            self.size = try container.decode(String.self, forKey: .size)
            self.region = try container.decode(String.self, forKey: .region)
            self.total = try container.decodeIfPresent(String.self, forKey: .total)
            // 原神的 gacha raw 没有 regionTimeZone。这里用一个假值取代之。
            // 反正伺服器的抽卡时区是固定的、是可以用 UID 倒推的。
            self.timeZoneDelta = try container.decodeIfPresent(Int.self, forKey: .timeZoneDelta) ?? 114_514
            self.list = try container.decode([FetchedEntry].self, forKey: .list)
        }

        // MARK: Public

        public let page: String
        public let size: String
        public let region: String
        public let total: String? // Genshin only. Might be totally useless.
        public let timeZoneDelta: Int
        public var list: [FetchedEntry]
        public var listConverted: [PZGachaEntrySendable] = []

        // MARK: Private

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        private enum CodingKeys: String, CodingKey {
            case page
            case size
            case total
            case region
            case timeZoneDelta = "region_time_zone"
            case list
        }
    }
}

// MARK: - GachaFetchModels.PageFetched.FetchedEntry

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaFetchModels.PageFetched {
    /// 专门用来解码伺服器远端抽卡记录的单笔资料结构，共用于绝区零、原神、星穹铁道的抽卡记录。
    ///
    /// 该结构忠实保留原有数据，不对时间做任何提前解码。所有属性都是 String。
    /// 唯一例外是原神没有 gachaID，自动补零处理。
    @available(iOS 17.0, *)
    @available(macCatalyst 17.0, *)
    @available(macOS 14.0, *)
    public struct FetchedEntry: GachaFetchModelTypeProtocol, Identifiable {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uid = try container.decode(String.self, forKey: .uid)
            self.gachaType = try container.decode(String.self, forKey: .gachaType)
            self.itemID = try container.decode(String.self, forKey: .itemID)
            self.count = try container.decode(String.self, forKey: .count)
            self.time = try container.decode(String.self, forKey: .time)
            self.name = try container.decode(String.self, forKey: .name)
            self.lang = try container.decode(String.self, forKey: .lang)
            self.itemType = try container.decode(String.self, forKey: .itemType)
            self.rankType = try container.decode(String.self, forKey: .rankType)
            self.id = try container.decode(String.self, forKey: .id)
            self.gachaID = try container.decodeIfPresent(String.self, forKey: .gachaID) ?? "0"
        }

        // MARK: Public

        public let uid: String
        public let gachaType: String
        public let itemID: String
        public let count: String
        public let time: String
        public let name: String
        public let lang: String
        public let itemType: String
        public let rankType: String
        public let id: String
        public let gachaID: String

        // MARK: Private

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        private enum CodingKeys: String, CodingKey {
            case uid
            case gachaType = "gacha_type"
            case itemID = "item_id"
            case count
            case time
            case name
            case lang
            case itemType = "item_type"
            case rankType = "rank_type"
            case id
            case gachaID = "gacha_id" // SR Only.
        }
    }
}
