// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HYQueriedModels.HYLAvatarDetail4GI

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels {
    public struct HYLAvatarDetail4GI: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            base: Base,
            weapon: ListWeapon,
            relics: [Relic],
            constellations: [Constellation],
            costumes: [Costume],
            selectedProperties: [PanelProperty],
            baseProperties: [PanelProperty],
            extraProperties: [PanelProperty],
            elementProperties: [PanelProperty],
            skills: [Skill],
            recommendRelicProperty: RecommendRelicProperty
        ) {
            self.base = base
            self.weapon = weapon
            self.relics = relics
            self.constellations = constellations
            self.costumes = costumes
            self.selectedProperties = selectedProperties
            self.baseProperties = baseProperties
            self.extraProperties = extraProperties
            self.elementProperties = elementProperties
            self.skills = skills
            self.recommendRelicProperty = recommendRelicProperty
        }

        // MARK: Public

        public typealias DBType = Enka.EnkaDB4GI

        public typealias List = [HYLAvatarDetail4GI]

        public struct DecodableList: DecodableHYLAvatarListProtocol {
            // MARK: Lifecycle

            public init(avatarList: HYLAvatarDetail4GI.List) {
                self.avatarList = avatarList
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case avatarList = "list"
            }

            public var avatarList: HYLAvatarDetail4GI.List
        }

        public enum CodingKeys: String, CodingKey {
            case base, weapon, relics, constellations, costumes
            case selectedProperties = "selected_properties"
            case baseProperties = "base_properties"
            case extraProperties = "extra_properties"
            case elementProperties = "element_properties"
            case skills
            case recommendRelicProperty = "recommend_relic_property"
        }

        public var base: Base
        public var weapon: ListWeapon
        public var relics: [Relic]
        public var constellations: [Constellation]
        public var costumes: [Costume]
        public var selectedProperties, baseProperties, extraProperties, elementProperties: [PanelProperty]
        public var skills: [Skill]
        public var recommendRelicProperty: RecommendRelicProperty?

        public var avatarIdStr: String {
            id.description
        }

        public var id: Int {
            base.id
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels.HYLAvatarDetail4GI {
    // MARK: - Base

    public struct Base: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            icon: String,
            name: String,
            element: String,
            fetter: Int,
            level: Int,
            rarity: Int,
            activedConstellationNum: Int,
            image: String,
            isChosen: Bool,
            sideIcon: String,
            weaponType: Int,
            weapon: BaseWeapon
        ) {
            self.id = id
            self.icon = icon
            self.name = name
            self.element = element
            self.fetter = fetter
            self.level = level
            self.rarity = rarity
            self.activedConstellationNum = activedConstellationNum
            self.image = image
            self.isChosen = isChosen
            self.sideIcon = sideIcon
            self.weaponType = weaponType
            self.weapon = weapon
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, icon, name, element, fetter, level, rarity
            case activedConstellationNum = "actived_constellation_num"
            case image
            case isChosen = "is_chosen"
            case sideIcon = "side_icon"
            case weaponType = "weapon_type"
            case weapon
        }

        public var id: Int
        public var icon: String
        public var name: String
        public var element: String
        public var fetter, level, rarity, activedConstellationNum: Int
        public var image: String
        public var isChosen: Bool
        public var sideIcon: String
        public var weaponType: Int
        public var weapon: BaseWeapon
    }

    // MARK: - BaseWeapon

    public struct BaseWeapon: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(id: Int, icon: String, type: Int, rarity: Int, level: Int, affixLevel: Int, name: String) {
            self.id = id
            self.icon = icon
            self.type = type
            self.rarity = rarity
            self.level = level
            self.affixLevel = affixLevel
            self.name = name
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, icon, type, rarity, level
            case affixLevel = "affix_level"
            case name
        }

        public var id: Int
        public var icon: String
        public var type, rarity, level, affixLevel: Int
        public var name: String
    }

    // MARK: - Property

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

    // MARK: - Constellation

    public struct Constellation: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            // name: String,
            icon: String,
            // effect: String,
            isActived: Bool,
            pos: Int
        ) {
            self.id = id
            // self.name = name
            self.icon = icon
            // self.effect = effect
            self.isActived = isActived
            self.pos = pos
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, icon
            // case name
            // case effect
            case isActived = "is_actived"
            case pos
        }

        public var id: Int
        // public var name: String
        public var icon: String
        // public var effect: String
        public var isActived: Bool
        public var pos: Int
    }

    // MARK: - Costume

    public struct Costume: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(id: Int, name: String, icon: String) {
            self.id = id
            self.name = name
            self.icon = icon
        }

        // MARK: Public

        public var id: Int
        public var name: String
        public var icon: String
    }

    // MARK: - Relic

    public struct Relic: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            // name: String,
            icon: String,
            pos: Int,
            rarity: Int,
            level: Int,
            relicSet: RelicSet,
            // posName: String,
            mainProperty: GameProperty,
            subPropertyList: [GameProperty]
        ) {
            self.id = id
            // self.name = name
            self.icon = icon
            self.pos = pos
            self.rarity = rarity
            self.level = level
            self.relicSet = relicSet
            // self.posName = posName
            self.mainProperty = mainProperty
            self.subPropertyList = subPropertyList
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, icon, pos, rarity, level
            // case name
            case relicSet = "set"
            // case posName = "pos_name"
            case mainProperty = "main_property"
            case subPropertyList = "sub_property_list"
        }

        public var id: Int
        // public var name: String
        public var icon: String
        public var pos, rarity, level: Int
        public var relicSet: RelicSet
        // public var posName: String
        public var mainProperty: GameProperty
        public var subPropertyList: [GameProperty]
    }

    // MARK: - MainProperty

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

    // MARK: - Set

    public struct RelicSet: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            // affixes: [RelicAffix],
            name: String
        ) {
            self.id = id
            self.name = name
            // self.affixes = affixes
        }

        // MARK: Public

        // MARK: - Affix

        public struct RelicAffix: AbleToCodeSendHash {
            // MARK: Lifecycle

            public init(activationNumber: Int, effect: String) {
                self.activationNumber = activationNumber
                self.effect = effect
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case activationNumber = "activation_number"
                case effect
            }

            public var activationNumber: Int
            public var effect: String
        }

        public var id: Int
        public var name: String
        // public var affixes: [RelicAffix]
    }

    // MARK: - Skill

    public struct Skill: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            skillID: Int,
            skillType: Int,
            level: Int,
            // desc: String,
            // skillAffixList: [SkillAffix],
            icon: String,
            // name: String,
            isUnlock: Bool
        ) {
            self.skillID = skillID
            self.skillType = skillType
            self.level = level
            // self.desc = desc
            // self.skillAffixList = skillAffixList
            self.icon = icon
            self.isUnlock = isUnlock
            // self.name = name
        }

        // MARK: Public

        // MARK: - SkillAffixList

        public struct SkillAffix: AbleToCodeSendHash {
            // MARK: Lifecycle

            public init(name: String, value: String) {
                self.name = name
                self.value = value
            }

            // MARK: Public

            public var name, value: String
        }

        public enum CodingKeys: String, CodingKey {
            case skillID = "skill_id"
            case skillType = "skill_type"
            case level
            // case desc
            // case skillAffixList = "skill_affix_list"
            case icon
            case isUnlock = "is_unlock"
            // case name
        }

        public var skillID, skillType, level: Int
        // public var desc: String
        // public var skillAffixList: [SkillAffix]
        public var icon: String
        public var isUnlock: Bool
        // public var name: String
    }

    // MARK: - ListWeapon

    public struct ListWeapon: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            id: Int,
            name: String,
            icon: String,
            type: Int,
            rarity: Int,
            level: Int,
            promoteLevel: Int,
            typeName: String,
            // desc: String,
            affixLevel: Int,
            mainProperty: PanelProperty,
            subProperty: PanelProperty?
        ) {
            self.id = id
            self.name = name
            self.icon = icon
            self.type = type
            self.rarity = rarity
            self.level = level
            self.promoteLevel = promoteLevel
            self.typeName = typeName
            // self.desc = desc
            self.affixLevel = affixLevel
            self.mainProperty = mainProperty
            self.subProperty = subProperty
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id, name, icon, type, rarity, level
            case promoteLevel = "promote_level"
            case typeName = "type_name"
            // case desc
            case affixLevel = "affix_level"
            case mainProperty = "main_property"
            case subProperty = "sub_property"
        }

        public var id: Int
        public var name: String
        public var icon: String
        public var type, rarity, level, promoteLevel: Int
        public var typeName: String
        // public var desc: String
        public var affixLevel: Int
        public var mainProperty: PanelProperty
        public var subProperty: PanelProperty?
    }
}

// MARK: - HYQueriedModels.HYLAvatarDetail4GI.RecommendRelicProperty

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels.HYLAvatarDetail4GI {
    // MARK: - RecommendRelicProperty

    public struct RecommendRelicProperty: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(recommendProperties: Properties, customProperties: Properties?, hasSetRecommendProp: Bool) {
            self.recommendProperties = recommendProperties
            self.customProperties = customProperties
            self.hasSetRecommendProp = hasSetRecommendProp
        }

        // MARK: Public

        public struct Properties: AbleToCodeSendHash {
            // MARK: Lifecycle

            public init(
                sandMainPropertyList: [Int],
                gobletMainPropertyList: [Int],
                circletMainPropertyList: [Int],
                subPropertyList: [Int]
            ) {
                self.sandMainPropertyList = sandMainPropertyList
                self.gobletMainPropertyList = gobletMainPropertyList
                self.circletMainPropertyList = circletMainPropertyList
                self.subPropertyList = subPropertyList
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case sandMainPropertyList = "sand_main_property_list"
                case gobletMainPropertyList = "goblet_main_property_list"
                case circletMainPropertyList = "circlet_main_property_list"
                case subPropertyList = "sub_property_list"
            }

            public var sandMainPropertyList, gobletMainPropertyList, circletMainPropertyList, subPropertyList: [Int]
        }

        public enum CodingKeys: String, CodingKey {
            case recommendProperties = "recommend_properties"
            case customProperties = "custom_properties"
            case hasSetRecommendProp = "has_set_recommend_prop"
        }

        public var recommendProperties: Properties
        public var customProperties: Properties?
        public var hasSetRecommendProp: Bool
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels.HYLAvatarDetail4GI {
    public static func exampleData() throws -> DecodableList {
        let exampleURL = Bundle.module.url(
            forResource: "HoYoLABAvatarListSample-GI",
            withExtension: "json"
        )!
        let exampleData = try Data(contentsOf: exampleURL)
        return try DecodableList.decodeFromMiHoYoAPIJSONResult(
            data: exampleData,
            debugTag: "HYQueriedModels.HYLAvatarDetail4GI.exampleData()"
        )
    }
}
