// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaDBModels

// MARK: - Enka.AvatarSummarized

extension Enka {
    /// The backend struct dedicated for rendering EachAvatarStatView.
    public struct AvatarSummarized: Codable, Hashable, Identifiable {
        // MARK: Public

        public let game: Enka.GameType
        public let mainInfo: AvatarMainInfo
        public let equippedWeapon: WeaponPanel?
        public let avatarPropertiesA: [Enka.PVPair]
        public let avatarPropertiesB: [Enka.PVPair]
        public private(set) var artifacts: [ArtifactInfo]

        // public var artifactRatingResult: ArtifactRating.ScoreResult?

        public var id: String { mainInfo.uniqueCharId } // 回头可能需要另外考虑。

        // MARK: Internal

        internal mutating func updateArtifacts(targetArray: @escaping ([ArtifactInfo]) -> [ArtifactInfo]) {
            artifacts = targetArray(artifacts)
        }
    }
}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo

extension Enka.AvatarSummarized {
    /// 专门用来负责管理角色证件照显示的 Identifiable Struct。
    public struct CharacterID: Identifiable, Codable, Hashable {
        // MARK: Lifecycle

        /// 通用建构子。
        public init?(id: String, costumeID: String? = nil) {
            let keys: [String] = [
                [String](Enka.Sputnik.shared.db4HSR.characters.keys),
                [String](Enka.Sputnik.shared.db4GI.characters.keys),
            ].reduce([], +)
            guard keys.contains(id) else { return nil }
            self.id = id
            self.nameObj = .init(pidStr: id)
            switch nameObj.game {
            case .genshinImpact:
                if let matched = Enka.Sputnik.shared.db4GI.characters[id] {
                    if let costumeID, let costume = matched.costumes?[costumeID] {
                        self.avatarAssetNameStem = "avatar_\(id)_\(costumeID)"
                        self.photoAssetNameStem = "characters_\(costumeID)"
                        self.avatarOnlineFileNameStem = costume.sideIconName.dropLast(5).description
                    } else {
                        self.avatarAssetNameStem = "avatar_\(id)"
                        self.photoAssetNameStem = "characters_\(id)"
                        self.avatarOnlineFileNameStem = matched.sideIconName.dropLast(5).description
                    }
                } else {
                    self.avatarAssetNameStem = "avatar_\(id)"
                    self.photoAssetNameStem = "characters_\(id)"
                    self.avatarOnlineFileNameStem = "\(id)"
                }
            case .starRail:
                self.avatarAssetNameStem = "avatar_\(id)"
                self.photoAssetNameStem = "characters_\(id)"
                self.avatarOnlineFileNameStem = "\(id)"
            }
        }

        // MARK: Public

        public let id: String
        public let nameObj: Enka.CharacterName
        public let avatarAssetNameStem: String
        public let photoAssetNameStem: String
        public let avatarOnlineFileNameStem: String

        public var game: Enka.GameType {
            nameObj.game
        }

        public var i18nNameForUI: String {
            nameObj.description
        }

        public var i18nNameFactoryVanilla: String {
            nameObj.officialDescription
        }
    }

    public struct AvatarMainInfo: Codable, Hashable {
        public let terms: Enka.ExtraTerms
        public let localizedName: String
        public let localizedRealName: String
        /// Unique Character ID number used by both Enka Network and MiHoYo.
        public let uniqueCharId: String
        /// Unique Character ID Expressable Object.
        public let idExpressable: Enka.AvatarSummarized.CharacterID
        /// Character's Mastered Element.
        public let element: Enka.GameElement
        /// Character's LifePath.
        public let lifePath: Enka.LifePath
        /// Avatar Level trained by the player.
        public let avatarLevel: Int
        /// Avatar constellation level.
        public let constellation: Int
        /// Base Skills.
        public let baseSkills: BaseSkillSet

        public var game: Enka.GameType {
            idExpressable.game
        }

        public var name: String {
            Defaults[.useRealCharacterNames] ? localizedRealName : localizedName
        }
    }
}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet

extension Enka.AvatarSummarized.AvatarMainInfo {
    /// Base Skill Set of a Character, excluding Technique since it doesn't have a level.
    public struct BaseSkillSet: Codable, Hashable {
        public struct BaseSkill: Codable, Hashable {
            public enum SkillType: String, Codable, Hashable {
                case basicAttack = "Normal"
                case elementalSkill = "BP"
                case elementalBurst = "Ultra"
                case talent = "Passive"
            }

            public let charIDStr: String
            /// Base skill level with amplification by constellations.
            public let baseLevel: Int
            public let levelAddition: Int?
            public let type: SkillType

            /// Game.
            public let game: Enka.GameType

            public let iconFileNameStem: String

            public var iconAssetName: String {
                "skill_\(charIDStr)_\(type.rawValue)"
            }
        }

        /// Basic Attack.
        public let basicAttack: BaseSkill
        /// Skill.
        public let elementalSkill: BaseSkill
        /// Ultimate.
        public let elementalBurst: BaseSkill
        /// Talent.
        public let talent: BaseSkill

        /// Game.
        public let game: Enka.GameType

        public var toArray: [BaseSkill] {
            [basicAttack, elementalSkill, elementalBurst, talent]
        }
    }
}

// MARK: - Enka.AvatarSummarized.WeaponPanel

extension Enka.AvatarSummarized {
    public struct WeaponPanel: Codable, Hashable {
        /// Game.
        public let game: Enka.GameType
        /// Unique Weapon ID.
        public let enkaId: Int
        public let localizedName: String
        public let trainedLevel: Int
        public let refinement: Int
        public let basicProps: [Enka.PVPair]
        public let specialProps: [Enka.PVPair]

        public let rarityStars: Int

        public var allProps: [Enka.PVPair] {
            basicProps + specialProps
        }

        public var iconFileName: String {
            "\(enkaId).heic"
        }

        public var iconAssetName: String {
            "light_cone_\(enkaId)"
        }
    }
}

// MARK: - Enka.AvatarSummarized.ArtifactInfo

extension Enka.AvatarSummarized {
    public struct ArtifactInfo: Codable, Hashable, Identifiable {
        /// Game.
        public let game: Enka.GameType
        /// Unique Artifact ID, defining its Rarity, Set Suite, and Body Part.
        public let enkaId: Int
        /// Artifact Set ID.
        public let setID: Int
        public let setNameLocalized: String
        public let mainProp: Enka.PVPair
        public let subProps: [Enka.PVPair]
        public var ratedScore: Int?
        public let type: Enka.ArtifactType
        public let trainedLevel: Int
        public let rarityStars: Int
        public let iconFileNameStem: String

        public var id: Int { enkaId }
        public var allProps: [Enka.PVPair] {
            var result = subProps
            result.insert(mainProp, at: 0)
            return result
        }

        public var iconAssetName: String {
            "relic_\(setID)_\(type.assetSuffix)"
        }
    }
}
