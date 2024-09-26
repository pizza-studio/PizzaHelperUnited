// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit

extension HoYo {
    public struct CharInventory4GI: CharacterInventory {
        public typealias AvatarType = HYAvatar4GI
        public typealias ViewType = CharacterInventoryView4GI

        public struct HYAvatar4GI: HYAvatar {
            // MARK: Public

            public struct Costume4GI: Codable, Sendable, Hashable {
                public var id: Int
                public var name: String
                public var icon: String
            }

            public struct Artifact4GI: Codable, Sendable, Hashable {
                // MARK: Public

                public struct Set: Codable, Sendable, Hashable {
                    public struct Affix: Codable, Sendable, Hashable {
                        // MARK: Public

                        public var activationNumber: Int
                        public var effect: String

                        // MARK: Internal

                        enum CodingKeys: String, CodingKey {
                            case activationNumber = "activation_number"
                            case effect
                        }
                    }

                    public var id: Int
                    public var name: String
                    public var affixes: [Affix]
                }

                public var pos: Int
                public var rarity: Int
                public var set: Set
                public var id: Int
                public var posName: String
                public var level: Int
                public var name: String
                public var icon: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case pos
                    case rarity
                    case set
                    case id
                    case posName = "pos_name"
                    case level
                    case name
                    case icon
                }
            }

            public struct Weapon4GI: Codable, Sendable, Hashable {
                // MARK: Public

                public var rarity: Int
                public var icon: String
                public var id: Int
                public var typeName: String
                public var level: Int
                public var affixLevel: Int
                public var type: Int
                public var promoteLevel: Int
                public var desc: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case rarity
                    case icon
                    case id
                    case typeName = "type_name"
                    case level
                    case affixLevel = "affix_level"
                    case type
                    case promoteLevel = "promote_level"
                    case desc
                }
            }

            public struct Constellation4GI: Codable, Sendable, Hashable {
                // MARK: Public

                public var effect: String
                public var id: Int
                public var icon: String
                public var name: String
                public var pos: Int
                public var isActived: Bool

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case effect
                    case id
                    case icon
                    case name
                    case pos
                    case isActived = "is_actived"
                }
            }

            public var id: Int
            public var element: String
            public var costumes: [Costume4GI]
            public var reliquaries: [Artifact4GI]
            public var level: Int
            public var image: String
            public var icon: String
            public var weapon: Weapon4GI
            public var fetter: Int
            public var constellations: [Constellation4GI]
            public var activedConstellationNum: Int
            public var name: String
            public var rarity: Int

            public var isProtagonist: Bool {
                switch id {
                case 10000005, 10000007: true
                default: false
                }
            }

            public static func == (
                lhs: HYAvatar4GI,
                rhs: HYAvatar4GI
            )
                -> Bool {
                lhs.id == rhs.id
            }

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case id
                case element
                case costumes
                case reliquaries
                case level
                case image
                case icon
                case weapon
                case fetter
                case constellations
                case activedConstellationNum = "actived_constellation_num"
                case name
                case rarity
            }
        }

        public var avatars: [HYAvatar4GI]
    }
}
