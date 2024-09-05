// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit

// MARK: - HoYo.TravelStatsData4HSR

extension HoYo {
    public struct TravelStatsData4HSR: TravelStats {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: HoYo.TravelStatsData4HSR.CodingKeys.self)

            self.stats = try container.decode(Stats.self, forKey: .stats)
            self.avatars = try container.decode([Avatar].self, forKey: .avatars)
        }

        // MARK: Public

        public typealias ViewType = TravelStatsView4HSR

        public var stats: Stats
        public var avatars: [Avatar]

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(stats, forKey: CodingKeys.stats)
            try container.encode(avatars, forKey: CodingKeys.avatars)
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case stats
            case worldExplorations = "world_explorations"
            case avatars = "avatar_list"
        }
    }
}

extension HoYo.TravelStatsData4HSR {
    public struct Stats: TravelStatsTable {
        // MARK: Public

        public let activeDays: Int
        public let avatarNum: Int
        public let achievementNum: Int
        public let chestNum: Int
        public let abyssProcess: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case activeDays = "active_days"
            case avatarNum = "avatar_num"
            case achievementNum = "achievement_num"
            case chestNum = "chest_num"
            case abyssProcess = "abyss_process"
        }
    }

    public struct Avatar: Codable, Hashable, Identifiable, Sendable {
        // MARK: Public

        public let id, rarity, rank: Int
        public let name, element, icon: String
        public let isChosen: Bool

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id, name, element, icon, rarity, rank
            case isChosen = "is_chosen"
        }
    }
}
