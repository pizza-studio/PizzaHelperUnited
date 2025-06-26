// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HYQueriedModels.HYLAvatarDetail4HSR

extension HYQueriedModels {
    public struct HYLAvatarDetail4HSR: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            level: Int,
            name: String,
            element: Element,
            icon: String,
            rarity: Int,
            rank: Int,
            image: String,
            equip: Equip?,
            relics: [Relic],
            ornaments: [Relic],
            eidolonResonanceList: [EidolonResonance],
            properties: [PanelProperty],
            skills: [Skill],
            baseType: Int,
            figurePath: String,
            elementID: Int
        ) {
            self.id = id
            self.level = level
            self.name = name
            self.element = element
            self.icon = icon
            self.rarity = rarity
            self.rank = rank
            self.image = image
            self.equip = equip
            self.relics = relics
            self.ornaments = ornaments
            self.eidolonResonanceList = eidolonResonanceList
            self.properties = properties
            self.skills = skills
            self.baseType = baseType
            self.figurePath = figurePath
            self.elementID = elementID
        }

        // MARK: Public

        public typealias DBType = Enka.EnkaDB4HSR
        public typealias List = [HYLAvatarDetail4HSR]

        public struct DecodableList: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
            // MARK: Lifecycle

            public init(avatarList: HYLAvatarDetail4HSR.List) {
                self.avatarList = avatarList
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case avatarList = "avatar_list"
            }

            public var avatarList: HYLAvatarDetail4HSR.List
        }

        public enum CodingKeys: String, CodingKey {
            case id, level, name, element, icon, rarity, rank, image, equip, relics, ornaments, properties,
                 skills
            case baseType = "base_type"
            case figurePath = "figure_path"
            case elementID = "element_id"
            case eidolonResonanceList = "ranks"
        }

        public var id, level: Int
        public var name: String
        public var element: Element
        public var icon: String
        public var rarity, rank: Int
        public var image: String
        public var equip: Equip?
        public var relics, ornaments: [Relic]
        public var eidolonResonanceList: [EidolonResonance]
        public var properties: [PanelProperty]
        public var skills: [Skill]
        public var baseType: Int
        public var figurePath: String
        public var elementID: Int

        public var avatarIdStr: String {
            id.description
        }
    }
}

extension HYQueriedModels.HYLAvatarDetail4HSR {
    public enum Element: String, AbleToCodeSendHash {
        case fire
        case ice
        case imaginary
        case lightning
        case physical
        case quantum
        case wind
    }

    // MARK: - Equip

    public struct Equip: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            level: Int,
            rank: Int,
            name: String,
            // desc: String,
            icon: String,
            rarity: Int
        ) {
            self.id = id
            self.level = level
            self.rank = rank
            self.name = name
            // self.desc = desc
            self.icon = icon
            self.rarity = rarity
        }

        // MARK: Public

        public var id, level, rank: Int
        public var name: String
        // public var desc: String
        public var icon: String
        public var rarity: Int
    }

    // MARK: - Ornament

    public struct Relic: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            level: Int,
            pos: Int,
            // name: String,
            // desc: String,
            icon: String,
            rarity: Int,
            mainProperty: GameProperty,
            properties: [GameProperty]
        ) {
            self.id = id
            self.level = level
            self.pos = pos
            // self.name = name
            // self.desc = desc
            self.icon = icon
            self.rarity = rarity
            self.mainProperty = mainProperty
            self.properties = properties
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, level, pos
            // case name
            // case desc
            case icon, rarity
            case mainProperty = "main_property"
            case properties
        }

        public var id, level, pos: Int
        // public var name, desc: String
        public var icon: String
        public var rarity: Int
        public var mainProperty: GameProperty
        public var properties: [GameProperty]
    }

    // MARK: - MainPropertyClass

    public struct GameProperty: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(propertyType: Int, value: String, times: Int) {
            self.propertyType = propertyType
            self.value = value
            self.times = times
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case propertyType = "property_type"
            case value, times
        }

        public var propertyType: Int
        public var value: String
        public var times: Int
    }

    // MARK: - PropertyElement

    public struct PanelProperty: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(propertyType: Int, base: String, add: String, propertyFinal: String) {
            self.propertyType = propertyType
            self.base = base
            self.add = add
            self.propertyFinal = propertyFinal
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case propertyType = "property_type"
            case base, add
            case propertyFinal = "final"
        }

        public var propertyType: Int
        public var base, add, propertyFinal: String
    }

    // MARK: - Rank

    public struct EidolonResonance: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            pos: Int,
            // name: String,
            icon: String,
            // desc: String,
            isUnlocked: Bool
        ) {
            self.id = id
            self.pos = pos
            // self.name = name
            self.icon = icon
            // self.desc = desc
            self.isUnlocked = isUnlocked
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, pos, icon
            // case name, desc
            case isUnlocked = "is_unlocked"
        }

        public var id, pos: Int
        // public var name: String
        public var icon: String
        // public var desc: String
        public var isUnlocked: Bool
    }

    // MARK: - Skill

    public struct Skill: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            pointID: String,
            pointType: Int,
            itemURL: String,
            level: Int,
            isActivated: Bool,
            isRankWork: Bool,
            prePoint: String,
            anchor: Anchor,
            remake: String,
            // skillStages: [SkillStage]
        ) {
            self.pointID = pointID
            self.pointType = pointType
            self.itemURL = itemURL
            self.level = level
            self.isActivated = isActivated
            self.isRankWork = isRankWork
            self.prePoint = prePoint
            self.anchor = anchor
            self.remake = remake
            // self.skillStages = skillStages
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case pointID = "point_id"
            case pointType = "point_type"
            case itemURL = "item_url"
            case level
            case isActivated = "is_activated"
            case isRankWork = "is_rank_work"
            case prePoint = "pre_point"
            case anchor, remake
            // case skillStages = "skill_stages"
        }

        public var pointID: String
        public var pointType: Int
        public var itemURL: String
        public var level: Int
        public var isActivated, isRankWork: Bool
        public var prePoint: String
        public var anchor: Anchor
        public var remake: String
        // public var skillStages: [SkillStage]
    }

    public enum Anchor: String, AbleToCodeSendHash {
        case point01 = "Point01"
        case point02 = "Point02"
        case point03 = "Point03"
        case point04 = "Point04"
        case point05 = "Point05"
        case point06 = "Point06"
        case point07 = "Point07"
        case point08 = "Point08"
        case point09 = "Point09"
        case point10 = "Point10"
        case point11 = "Point11"
        case point12 = "Point12"
        case point13 = "Point13"
        case point14 = "Point14"
        case point15 = "Point15"
        case point16 = "Point16"
        case point17 = "Point17"
        case point18 = "Point18"
    }

    // MARK: - SkillStage

    public struct SkillStage: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            desc: String,
            name: String,
            level: Int,
            remake: String,
            itemURL: String,
            isActivated: Bool,
            isRankWork: Bool
        ) {
            self.desc = desc
            self.name = name
            self.level = level
            self.remake = remake
            self.itemURL = itemURL
            self.isActivated = isActivated
            self.isRankWork = isRankWork
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case desc, name, level, remake
            case itemURL = "item_url"
            case isActivated = "is_activated"
            case isRankWork = "is_rank_work"
        }

        public var desc, name: String
        public var level: Int
        public var remake: String
        public var itemURL: String
        public var isActivated, isRankWork: Bool
    }
}

extension HYQueriedModels.HYLAvatarDetail4HSR {
    public static func exampleData() throws -> DecodableList {
        let exampleURL = Bundle.module.url(
            forResource: "HoYoLABAvatarListSample-HSR",
            withExtension: "json"
        )!
        let exampleData = try Data(contentsOf: exampleURL)
        return try DecodableList.decodeFromMiHoYoAPIJSONResult(
            data: exampleData,
            debugTag: "HYQueriedModels.HYLAvatarDetail4HSR.exampleData()"
        )
    }
}
