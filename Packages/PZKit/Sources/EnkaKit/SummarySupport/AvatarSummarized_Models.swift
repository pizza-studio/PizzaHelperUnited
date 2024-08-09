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
        public let avatarPropertiesA: [PropertyPair]
        public let avatarPropertiesB: [PropertyPair]
        public private(set) var artifacts: [ArtifactInfo]

        // public var artifactRatingResult: ArtifactRating.ScoreResult?

        public var id: Int { mainInfo.uniqueCharId } // 回头可能需要另外考虑。

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
        public init?(id: String) {
            guard Enka.Sputnik.shared.db4HSR.characters.keys.contains(id) else { return nil }
            self.id = id
            self.nameObj = .init(pidStr: id)
        }

        // MARK: Public

        public let id: String

        public let nameObj: Enka.CharacterName

        public var game: Enka.GameType {
            nameObj.game
        }

        public var i18nNameForUI: String {
            nameObj.description
        }

        public var i18nNameFactoryVanilla: String {
            nameObj.officialDescription
        }

        public var avatarAssetNameStem: String {
            "avatar_\(id)"
        }

        public var photoAssetNameStem: String {
            "characters_\(id)"
        }
    }

    public struct AvatarMainInfo: Codable, Hashable {
        public let terms: Enka.ExtraTerms
        public let localizedName: String
        public let localizedRealName: String
        /// Unique Character ID number used by both Enka Network and MiHoYo.
        public let uniqueCharId: Int
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

            public var iconFileNameStem: String {
                "\(charIDStr)_\(type.rawValue)"
            }

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

// MARK: - Enka.AvatarSummarized.PropertyPair

extension Enka.AvatarSummarized {
    public struct PropertyPair: Codable, Hashable, Identifiable {
        /// Game.
        public let game: Enka.GameType
        public let type: Enka.PropertyType
        public let value: Double
        public let localizedTitle: String
        public let isArtifact: Bool
        public let count: Int
        public let step: Int?

        public var id: Enka.PropertyType { type }

        public var valueString: String {
            var copiedValue = value
            let prefix = isArtifact ? "+" : ""
            if type.isPercentage {
                copiedValue *= 100
                return prefix + copiedValue.roundToPlaces(places: 1).description + "%"
            }
            return prefix + Int(copiedValue).description
        }

        public var iconFileName: String? {
            type.iconFileName
        }

        public var iconAssetName: String? {
            type.iconAssetName
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
        /// Common information fetched from EnkaDB.
        public let commonInfo: EnkaDBModelsHSR.Weapon
        /// Data from Enka query result profile.
        public let paramDataFetched: Enka.QueriedProfileHSR.Equipment
        public let localizedName: String
        public let trainedLevel: Int
        public let refinement: Int
        public let basicProps: [PropertyPair]
        public let specialProps: [PropertyPair]

        public var rarityStars: Int { commonInfo.rarity }

        public var allProps: [PropertyPair] {
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
        /// Common information fetched from EnkaDB.
        public let commonInfo: EnkaDBModelsHSR.Artifact
        /// Data from Enka query result profile.
        public let paramDataFetched: Enka.QueriedProfileHSR.ArtifactItem
        public let mainProp: PropertyPair
        public let subProps: [PropertyPair]

        public var ratedScore: Int?

        public let type: Enka.ArtifactType

        public var trainedLevel: Int { paramDataFetched.level ?? 0 }
        public var rarityStars: Int { commonInfo.rarity }
        public var id: Int { enkaId }
        public var allProps: [PropertyPair] {
            var result = subProps
            result.insert(mainProp, at: 0)
            return result
        }

        public var iconFileName: String {
            "\(commonInfo.setID)_\(type.assetSuffix).heic"
        }

        public var iconAssetName: String {
            "relic_\(commonInfo.setID)_\(type.assetSuffix)"
        }
    }
}

// MARK: - Swift Extension to round doubles.

extension Double {
    /// Rounds the double to decimal places value
    fileprivate func roundToPlaces(places: Int = 1) -> Double {
        guard places > 0 else { return self }
        var precision = 1.0
        for _ in 0 ..< places {
            precision *= 10
        }
        return Double((precision * self).rounded() / precision)
    }
}
