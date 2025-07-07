// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.CharInventory4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct CharInventory4HSR: CharacterInventory {
        // MARK: Public

        public typealias AvatarType = HYAvatar4HSR

        public struct HYAvatar4HSR: HYAvatar {
            public let id: Int // 七大基础参数之一
            public let level: Int // 七大基础参数之一
            public let name: String // 七大基础参数之一
            public let element: String // 七大基础参数之一
            public let icon: String // 七大基础参数之一
            public let rarity: Int // 七大基础参数之一
            public let rank: Int // 七大基础参数之一；命之座
            public let image: String? // 无法在 basic 模式下提供
            public let equip: HYEquip4HSR? // 无法在 basic 模式下提供
            public let relics: [HYArtifactOuter4HSR]? // 无法在 basic 模式下提供
            public let ornaments: [HYArtifactInner4HSR]? // 无法在 basic 模式下提供
            public let ranks: [HYSkillRank4HSR]? // 技能樹；无法在 basic 模式下提供

            public var allArtifacts: [any HoyoArtifactProtocol4HSR] {
                var result = [any HoyoArtifactProtocol4HSR]()
                result.append(contentsOf: relics ?? [])
                result.append(contentsOf: ornaments ?? [])
                return result
            }
        }

        public let avatars: [HYAvatar4HSR]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case avatars = "avatar_list"
        }
    }
}

// MARK: - HoyoArtifactProtocol4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol HoyoArtifactProtocol4HSR: AbleToCodeSendHash, Identifiable {
    var id: Int { get }
    var level: Int { get }
    var pos: Int { get }
    var name: String { get }
    var desc: String { get }
    var icon: String { get }
    var rarity: Int { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.CharInventory4HSR.HYAvatar4HSR {
    public struct HYEquip4HSR: AbleToCodeSendHash, Identifiable {
        public let id: Int
        public let level: Int
        public let rank: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYArtifactOuter4HSR: HoyoArtifactProtocol4HSR {
        public let id: Int
        public let level: Int
        public let pos: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYArtifactInner4HSR: HoyoArtifactProtocol4HSR {
        public let id: Int
        public let level: Int
        public let pos: Int
        public let name: String
        public let desc: String
        public let icon: String
        public let rarity: Int
    }

    public struct HYSkillRank4HSR: AbleToCodeSendHash, Identifiable {
        // MARK: Public

        public let id: Int
        public let pos: Int
        public let name: String
        public let icon: String
        public let desc: String
        public let isUnlocked: Bool

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case isUnlocked = "is_unlocked"
            case id, pos, name, icon, desc
        }
    }
}
