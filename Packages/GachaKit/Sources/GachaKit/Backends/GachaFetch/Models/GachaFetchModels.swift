// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GachaFetchModelType

protocol GachaFetchModelType: Decodable, Hashable, Equatable {}

// MARK: - GachaFetchModels

/// Namespaces holding all types used for decoding raw remote JSON data of Gacha Records from HoYo servers.
///
/// This namespaces is intensionally made non-public.
enum GachaFetchModels {}

// MARK: - GachaFetchModelError

/// This, as an exception, is public.
public enum GachaFetchModelError: Error, LocalizedError {
    case retrievalFailure(retCode: Int, message: String)

    // MARK: Public

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

// MARK: GachaFetchModels.PageFetched

extension GachaFetchModels {
    struct RawResponseModel: GachaFetchModelType {
        // MARK: Lifecycle

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.retcode = try container.decode(Int.self, forKey: .retcode)
            self.message = try container.decode(String.self, forKey: .message)
            let data = try container.decodeIfPresent(GachaFetchModels.PageFetched.self, forKey: .data)
            guard let data else {
                throw GachaFetchModelError.retrievalFailure(retCode: retcode, message: message)
            }
            self.data = data
        }

        // MARK: Internal

        let retcode: Int
        let message: String
        let data: PageFetched

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case retcode
            case message
            case data
        }
    }

    /// 专门用来解码伺服器远端抽卡记录的单页资料结构，共用于绝区零、原神、星穹铁道的抽卡记录。
    struct PageFetched: GachaFetchModelType {
        // MARK: Lifecycle

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.page = try container.decode(String.self, forKey: .page)
            self.size = try container.decode(String.self, forKey: .size)
            self.region = try container.decode(String.self, forKey: .region)
            self.total = try container.decodeIfPresent(String.self, forKey: .total)
            self.timeZoneDelta = try container.decode(Int.self, forKey: .timeZoneDelta)
            self.list = try container.decode([PageFetched].self, forKey: .list)
        }

        // MARK: Internal

        let page: String
        let size: String
        let region: String
        let total: String? // Genshin only. Might be totally useless.
        let timeZoneDelta: Int
        let list: [PageFetched]

        // MARK: Private

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

extension GachaFetchModels.PageFetched {
    /// 专门用来解码伺服器远端抽卡记录的单笔资料结构，共用于绝区零、原神、星穹铁道的抽卡记录。
    ///
    /// 该结构忠实保留原有数据，不对时间做任何提前解码。所有属性都是 String。
    /// 唯一例外是原神没有 gachaID，自动补零处理。
    struct FetchedEntry: GachaFetchModelType, Identifiable {
        // MARK: Lifecycle

        init(from decoder: any Decoder) throws {
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

        // MARK: Internal

        let uid: String
        let gachaType: String
        let itemID: String
        let count: String
        let time: String
        let name: String
        let lang: String
        let itemType: String
        let rankType: String
        let id: String
        let gachaID: String

        // MARK: Private

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
