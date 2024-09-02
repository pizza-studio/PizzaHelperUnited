// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// Ref: https://github.com/KimigaiiWuyi/GenshinUID/commit/426540cfae511faf5f2b1a2414b1125431bfb773
// data = cast(Array[Avatar4GI], data['data']['list'])
// "/game_record/app/genshin/api/character/detail"
// 这与米游社 / HoYoLAB 的 CharacterInventory 的资料模型还是有出入的。

extension HYQueriedModels {
    public struct Avatar4GI: Codable {
        // MARK: Public

        public struct CharacterMeta: Codable {
            // MARK: Public

            public let id: Int
            public let icon: String
            public let name: String
            public let element: String
            public let fetter: Int
            public let level: Int
            public let rarity: Int
            public let constellationLevel: Int
            public let image: String
            public let isChosen: Bool
            public let sideIcon: String
            public let weaponType: Int
            public let weapon: Weapon

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id, icon, name, element, fetter, level, rarity, image
                case constellationLevel = "actived_constellation_num"
                case isChosen = "is_chosen"
                case sideIcon = "side_icon"
                case weaponType = "weapon_type"
                case weapon
            }
        }

        public struct PropertyPair: Codable {
            // MARK: Public

            public let propertyType: Int
            public let base: String
            public let add: String
            public let final: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case propertyType = "property_type"
                case base, add, final
            }
        }

        public struct Skill: Codable {
            // MARK: Public

            public struct SkillAffix: Codable {
                public let name: String
                public let value: String
            }

            public let skillId: Int
            public let skillType: Int
            public let level: Int
            public let desc: String
            public let skillAffixList: [SkillAffix]
            public let icon: String
            public let isUnlock: Bool
            public let name: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case skillId = "skill_id"
                case skillType = "skill_type"
                case level, desc, icon, name
                case skillAffixList = "skill_affix_list"
                case isUnlock = "is_unlock"
            }
        }

        public struct Constellation: Codable {
            // MARK: Public

            public let id: Int
            public let name: String
            public let icon: String
            public let effect: String
            public let isActived: Bool
            public let pos: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id, name, icon, effect, pos
                case isActived = "is_actived"
            }
        }

        // MARK: - Weapon public structs

        public struct Weapon: Codable {
            // MARK: Public

            public struct MainProperty: Codable {
                // MARK: Public

                public let propertyType: Int
                public let base: String
                public let add: String
                public let final: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case propertyType = "property_type"
                    case base, add, final
                }
            }

            public struct SubProperty: Codable {
                // MARK: Public

                public let propertyType: Int
                public let base: String
                public let add: String
                public let final: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case propertyType = "property_type"
                    case base, add, final
                }
            }

            public let id: Int
            public let name: String
            public let icon: String
            public let type: Int
            public let rarity: Int
            public let level: Int
            public let promoteLevel: Int
            public let typeName: String
            public let desc: String
            public let affixLevel: Int
            public let mainProperty: MainProperty
            public let subProperty: SubProperty

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id, name, icon, type, rarity, level
                case promoteLevel = "promote_level"
                case typeName = "type_name"
                case desc
                case affixLevel = "affix_level"
                case mainProperty = "main_property"
                case subProperty = "sub_property"
            }
        }

        // MARK: - Relic public structs

        public struct Relic: Codable {
            // MARK: Public

            public struct RelicSet: Codable {
                // MARK: Public

                public let id: Int
                public let name: String
                public let affixes: [String: String]

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case id, name, affixes
                }
            }

            public struct RelicMainProperty: Codable {
                // MARK: Public

                public let propertyType: Int
                public let value: String
                public let times: Int

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case propertyType = "property_type"
                    case value, times
                }
            }

            public struct RelicSubProperty: Codable {
                // MARK: Public

                public let propertyType: Int
                public let value: String
                public let times: Int

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case propertyType = "property_type"
                    case value, times
                }
            }

            public let id: Int
            public let name: String
            public let icon: String
            public let pos: Int
            public let rarity: Int
            public let level: Int
            public let set: RelicSet
            public let posName: String
            public let mainProperty: RelicMainProperty
            public let subPropertyList: [RelicSubProperty]

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id, name, icon, pos, rarity, level, set
                case posName = "pos_name"
                case mainProperty = "main_property"
                case subPropertyList = "sub_property_list"
            }
        }

        public let base: CharacterMeta
        public let weapon: Weapon
        public let relics: [Relic]
        public let constellations: [Constellation]
        public let costumes: [String: String]
        public let selectedProperties: [PropertyPair]
        public let baseProperties: [PropertyPair]
        public let extraProperties: [PropertyPair]
        public let elementProperties: [PropertyPair]
        public let skills: [Skill]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case base, weapon, relics, constellations, costumes
            case selectedProperties = "selected_properties"
            case baseProperties = "base_properties"
            case extraProperties = "extra_properties"
            case elementProperties = "element_properties"
            case skills
        }
    }
}
