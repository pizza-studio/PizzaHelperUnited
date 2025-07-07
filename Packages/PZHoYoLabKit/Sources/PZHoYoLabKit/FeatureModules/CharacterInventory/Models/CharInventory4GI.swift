// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.CharInventory4GI

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct CharInventory4GI: CharacterInventory {
        public typealias AvatarType = HYAvatar4GI

        public struct HYAvatar4GI: HYAvatar {
            // MARK: Public

            public struct Weapon4GI: AbleToCodeSendHash {
                // MARK: Public

                public var id: Int
                public var icon: String
                public var type: Int
                public var rarity: Int
                public var level: Int
                public var affixLevel: Int

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case rarity
                    case icon
                    case id
                    case type
                    case level
                    case affixLevel = "affix_level"
                }
            }

            public var id: Int
            public var icon: String
            public var name: String
            public var element: String
            public var fetter: Int
            public var level: Int
            public var rarity: Int
            public var activedConstellationNum: Int
            public var image: String
            public var weapon: Weapon4GI
            public var relicIconURLs: [String]? // 备用栏位。原始解读资料里面没有这一项。
            public var relicIDs: [Int]? // 备用栏位。原始解读资料里面没有这一项。
            public var relicSetIDs: [Int]? // 备用栏位。原始解读资料里面没有这一项。
            public var costumeIDs: [Int]? // 备用栏位。原始解读资料里面没有这一项。

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
                case level
                case image
                case icon
                case weapon
                case fetter
                case activedConstellationNum = "actived_constellation_num"
                case name
                case rarity
            }
        }

        public var list: [HYAvatar4GI]

        public var avatars: [HYAvatar4GI] { list }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.CharInventory4GI {
    public struct AvatarDetailPackage4GI: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        public var list: [AvatarDetail4GI]
    }

    /// 此处仅取用会用到的资讯。
    public struct AvatarDetail4GI: AbleToCodeSendHash {
        public struct Costume4GI: AbleToCodeSendHash {
            public var id: Int
            public var name: String
            public var icon: String
        }

        public struct Relic4GI: AbleToCodeSendHash {
            public var id: Int
            public var set: RelicSet4GI
            public var icon: String
        }

        public struct RelicSet4GI: AbleToCodeSendHash {
            public struct RelicSetAffix4GI: AbleToCodeSendHash {
                // MARK: Public

                public let activationNumber: Int

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case activationNumber = "activation_number"
                }
            }

            public let id: Int
            public let name: String
            public let affixes: [RelicSetAffix4GI]
        }

        public var base: HYAvatar4GI
        public var relics: [Relic4GI]?
        public var costumes: [Costume4GI]?
    }
}
