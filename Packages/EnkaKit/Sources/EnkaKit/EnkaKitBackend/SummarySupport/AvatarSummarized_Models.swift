// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaDBModels

// MARK: - Enka.AvatarSummarized

extension Enka {
    /// The backend struct dedicated for rendering EachAvatarStatView.
    public struct AvatarSummarized: Codable, Hashable, Sendable, Identifiable {
        // MARK: Public

        public let game: Enka.GameType
        public let mainInfo: AvatarMainInfo
        public let equippedWeapon: WeaponPanel?
        public let avatarPropertiesA: [Enka.PVPair]
        public let avatarPropertiesB: [Enka.PVPair]
        public private(set) var artifacts: [ArtifactInfo]

        public var artifactRatingResult: ArtifactRating.ScoreResult?

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
    public struct CharacterID: Identifiable, Codable, Hashable, Sendable {
        // MARK: Lifecycle

        /// 通用建构子。
        public init?(id: String, costumeID: String? = nil) {
            let keys1 = Array(Enka.Sputnik.shared.db4HSR.characters.keys)
            let keys2 = Enka.Sputnik.shared.db4GI.characters.keys
            guard (keys1 + keys2).contains(id) else { return nil }
            self.idSansCostume = id
            var newIdStr = id
            if let costumeID {
                newIdStr += "_\(costumeID)"
            }
            self.id = newIdStr
            self.nameObj = .init(pidStr: newIdStr)
            switch nameObj.game {
            case .genshinImpact:
                guard let matched = Enka.Sputnik.shared.db4GI.characters[id] else { return nil }
                var onlineFileNameStem = Self.convertIconName(from: matched.sideIconName)
                if let costumeID, let costume = matched.costumes?[costumeID] {
                    onlineFileNameStem = Self.convertIconName(from: costume.sideIconName)
                }
                self.iconOnlineFileNameStem = onlineFileNameStem
                switch nameObj {
                case .someoneElse:
                    self.iconAssetName = "gi_character_\(self.id)"
                case .protagonist:
                    self.iconAssetName = "gi_character_\(idSansCostume.prefix(8))"
                }
            case .starRail:
                self.iconAssetName = "hsr_character_\(id)"
                self.iconOnlineFileNameStem = "\(id)"
            case .zenlessZone:
                self.iconAssetName = "zzz_character_\(id)" // 临时设定。
                self.iconOnlineFileNameStem = "\(id)" // 临时设定。
            }
        }

        // MARK: Public

        public let id: String
        public let idSansCostume: String
        public let nameObj: Enka.CharacterName
        public let iconAssetName: String
        public let iconOnlineFileNameStem: String

        public var isProtagonist: Bool {
            switch nameObj {
            case .protagonist: true
            case .someoneElse: false
            }
        }

        public var game: Enka.GameType {
            nameObj.game
        }

        public var i18nNameForUI: String {
            nameObj.description
        }

        public var i18nNameFactoryVanilla: String {
            nameObj.officialDescription
        }

        // MARK: Private

        /// 原神专用。
        private static func convertIconName(from sideIconName: String) -> String {
            sideIconName.replacingOccurrences(of: "_Side", with: "")
        }
    }

    public struct AvatarMainInfo: Codable, Hashable, Sendable {
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
    public struct BaseSkillSet: Codable, Hashable, Sendable {
        public struct BaseSkill: Codable, Hashable, Sendable {
            public enum SkillType: String, Codable, Hashable, Sendable {
                case basicAttack = "Normal"
                case elementalSkill = "BP"
                case elementalBurst = "Ultra"
                case talent = "Passive"
            }

            public let charIDStr: String
            /// Base skill level without amplification by constellations.
            public let baseLevel: Int
            public let levelAddition: Int?
            public let type: SkillType
            public let game: Enka.GameType
            public let iconAssetName: String
            public var iconOnlineFileNameStem: String
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
    public struct WeaponPanel: Codable, Hashable, Sendable {
        /// Game.
        public let game: Enka.GameType
        /// Unique Weapon ID.
        public let weaponID: Int
        public let localizedName: String
        public let trainedLevel: Int
        public let refinement: Int
        public let basicProps: [Enka.PVPair]
        public let specialProps: [Enka.PVPair]
        public let iconAssetName: String
        public var iconOnlineFileNameStem: String

        public let rarityStars: Int

        public var allProps: [Enka.PVPair] {
            basicProps + specialProps
        }
    }
}

// MARK: - Enka.AvatarSummarized.ArtifactInfo

extension Enka.AvatarSummarized {
    public struct ArtifactInfo: Codable, Hashable, Sendable, Identifiable {
        /// Game.
        public let game: Enka.GameType
        /// Unique Artifact ID, defining its Rarity, Set Suite, and Body Part.
        public let itemID: Int
        /// Artifact Set ID.
        public let setID: Int
        public let setNameLocalized: String
        public let mainProp: Enka.PVPair
        public let subProps: [Enka.PVPair]
        public var ratedScore: Int?
        public let type: Enka.ArtifactType
        public let trainedLevel: Int
        public let rarityStars: Int
        public let iconAssetName: String
        public var iconOnlineFileNameStem: String

        public var id: Int { itemID }
        public var allProps: [Enka.PVPair] {
            var result = subProps
            result.insert(mainProp, at: 0)
            return result
        }
    }
}
