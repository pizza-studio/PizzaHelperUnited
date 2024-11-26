// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.TravelStatsData4GI

extension HoYo {
    public struct TravelStatsData4GI: TravelStats {
        // MARK: Public

        public typealias ViewType = TravelStatsView4GI

        public struct Stats: TravelStatsTable {
            // MARK: Public

            /// 解锁角色数
            public var avatarNumber: Int
            /// 精致宝箱数
            public var exquisiteChestNumber: Int
            /// 普通宝箱数
            public var commonChestNumber: Int
            /// 解锁传送点数量
            public var wayPointNumber: Int
            /// 岩神瞳
            public var geoculusNumber: Int
            /// 草神瞳
            public var dendroculusNumber: Int
            /// 解锁成就数
            public var achievementNumber: Int
            /// 解锁秘境数量
            public var domainNumber: Int
            /// 活跃天数
            public var activeDayNumber: Int
            /// 风神瞳
            public var anemoculusNumber: Int
            /// 华丽宝箱数
            public var luxuriousChestNumber: Int
            /// 雷神瞳
            public var electroculusNumber: Int
            /// 水神瞳
            public var hydroculusNumber: Int
            /// 火神瞳
            public var pyroculusNumber: Int
            /// 冰神瞳
            public var cryoculusNumber: Int? // 直到原神 6.0 再把这个 field 设为 non-nullable。
            /// 珍贵宝箱数
            public var preciousChestNumber: Int
            /// 深境螺旋
            public var spiralAbyss: String
            /// 奇馈宝箱数
            public var magicChestNumber: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case avatarNumber = "avatar_number"
                case exquisiteChestNumber = "exquisite_chest_number"
                case commonChestNumber = "common_chest_number"
                case wayPointNumber = "way_point_number"
                case geoculusNumber = "geoculus_number"
                case dendroculusNumber = "dendroculus_number"
                case achievementNumber = "achievement_number"
                case domainNumber = "domain_number"
                case activeDayNumber = "active_day_number"
                case anemoculusNumber = "anemoculus_number"
                case luxuriousChestNumber = "luxurious_chest_number"
                case electroculusNumber = "electroculus_number"
                case hydroculusNumber = "hydroculus_number"
                case pyroculusNumber = "pyroculus_number"
                case cryoculusNumber = "cryoculus_number"
                case preciousChestNumber = "precious_chest_number"
                case spiralAbyss = "spiral_abyss"
                case magicChestNumber = "magic_chest_number"
            }
        }

        public struct WorldExploration: AbleToCodeSendHash {
            // MARK: Public

            public struct Offering: AbleToCodeSendHash {
                public var name: String
                public var level: Int
                public var icon: String
            }

            public var id: Int
            public var backgroundImage: String
            public var mapUrl: String
            public var parentID: Int
            public var type: String
            public var offerings: [Offering]
            public var level: Int
            public var explorationPercentage: Int
            public var icon: String
            public var innerIcon: String
            public var cover: String
            public var name: String
            public var strategyUrl: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id
                case backgroundImage = "background_image"
                case mapUrl = "map_url"
                case parentID = "parent_id"
                case type
                case offerings
                case level
                case explorationPercentage = "exploration_percentage"
                case icon
                case innerIcon = "inner_icon"
                case cover
                case name
                case strategyUrl = "strategy_url"
            }
        }

        public struct Avatar: Codable, Identifiable, Hashable, Sendable {
            // MARK: Public

            public var fetter: Int
            public var rarity: Int
            public var cardImage: String
            public var id: Int
            public var isChosen: Bool
            public var element: String
            public var image: String
            public var level: Int
            public var name: String
            public var activedConstellationNum: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case fetter
                case rarity
                case cardImage = "card_image"
                case id
                case isChosen = "is_chosen"
                case element
                case image
                case level
                case name
                case activedConstellationNum = "actived_constellation_num"
            }
        }

        public var stats: Stats
        public var worldExplorations: [WorldExploration]
        public var avatars: [Avatar]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case stats
            case worldExplorations = "world_explorations"
            case avatars
        }
    }
}

// MARK: - Extending [Offering]

extension Array where Element == HoYo.TravelStatsData4GI.WorldExploration {
    public var sortedDataWithDeduplication: [HoYo.TravelStatsData4GI.WorldExploration] {
        var offered: Set<HoYo.TravelStatsData4GI.WorldExploration.Offering> = .init()
        var result = [HoYo.TravelStatsData4GI.WorldExploration]()
        let chenyuValePercent: Int = reversed().compactMap { this in
            if this.icon.contains("ChenYuVale") || this.innerIcon.contains("ChenYuVale") {
                !this.offerings.isEmpty ? 0 : this.explorationPercentage
            } else {
                nil
            }
        }.reduce(0, +)
        var chenyuValeAlreadyAdded = false
        forEach { this in
            var this = this
            let chenyuStr = "ChenYuVale"
            chenyu: if this.icon.contains(chenyuStr) || this.innerIcon.contains(chenyuStr) {
                if !chenyuValeAlreadyAdded, !this.offerings.isEmpty {
                    chenyuValeAlreadyAdded = true
                    this.explorationPercentage = Int((Double(chenyuValePercent) / 3).rounded(.down))
                    break chenyu
                }
                return
            }
            let oldOfferings = this.offerings
            this.offerings.removeAll()
            oldOfferings.forEach { offering in
                guard !offered.contains(offering) else { return }
                this.offerings.append(offering)
                offered.insert(offering)
            }
            // 从伺服器拿到的资料是反序排列的，这里给它正过来。
            result.insert(this, at: result.startIndex)
        }
        return result
    }
}

extension HoYo.TravelStatsData4GI.WorldExploration {
    public var fallbackLocalAssetName: String? {
        for (key, value) in Self.countryIconConversionMap {
            if icon.contains(key) {
                return "gi_travelStats_\(value)"
            }
        }
        return nil
    }

    private static let countryIconConversionMap: [String: String] = [
        "UI_ChapterIcon_Nata": "Emblem_Natlan_White",
        "UI_ChapterIcon_TheOldSea": "Emblem_Sea_of_Bygone_Eras_White",
        "UI_ChapterIcon_Fengdan": "Emblem_Fontaine_White",
        "UI_ChapterIcon_Xumi": "Emblem_Sumeru_White",
        "UI_ChapterIcon_ChasmsMaw": "Emblem_The_Chasm_White",
        "UI_ChapterIcon_Enkanomiya": "Emblem_Enkanomiya_White",
        "UI_ChapterIcon_Daoqi": "Emblem_Inazuma_White",
        "UI_ChapterIcon_Dragonspine": "Emblem_Dragonspine_White",
        "UI_ChapterIcon_Liyue": "Emblem_Liyue_White",
        "UI_ChapterIcon_Mengde": "Emblem_Mondstadt_White",
        "UI_ChapterIcon_ChenYuVale": "Emblem_Chenyu_Vale_White",
    ]
}
