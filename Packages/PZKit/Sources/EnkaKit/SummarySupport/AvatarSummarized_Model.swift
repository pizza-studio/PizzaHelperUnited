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
        // MARK: Lifecycle

        /// 星穹铁道专用建构子。
        public init?(
            hsrDB: Enka.EnkaDB4HSR,
            charID: Int,
            avatarLevel avatarLv: Int,
            constellation constellationLevel: Int,
            baseSkills baseSkillSet: BaseSkillSet
        ) {
            guard let theCommonInfo = hsrDB.characters[charID.description] else { return nil }
            guard let idExpressible = Enka.AvatarSummarized.CharacterID(id: charID.description) else { return nil }
            guard let lifePath = Enka.LifePath(rawValue: theCommonInfo.avatarBaseType) else { return nil }
            guard let theElement = Enka.GameElement(rawValue: theCommonInfo.element) else { return nil }
            self.avatarLevel = avatarLv
            self.constellation = constellationLevel
            self.baseSkills = baseSkillSet
            self.uniqueCharId = charID
            self.element = theElement
            self.lifePath = lifePath
            let nameTyped = Enka.CharacterName(pid: charID)
            self.localizedName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: true)
            self.localizedRealName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: false)
            self.terms = .init(lang: hsrDB.locTag, game: .starRail)
            self.idExpressable = idExpressible
            guard game == .starRail else { return nil }
        }

        // MARK: Public

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
        // MARK: Lifecycle

        /// 星穹铁道专用建构子。
        public init?(
            hsrDB: Enka.EnkaDB4HSR,
            constellation: Int,
            fetched: [Enka.QueriedProfileHSR.SkillTreeItem]
        ) {
            guard fetched.count >= 4, let firstTreeItem = fetched.first else { return nil }
            let charIDStr = firstTreeItem.pointId.description.prefix(4).description
            var levelAdditionList = [String: Int]()
            if constellation > 1 {
                for i in 1 ... constellation {
                    let keyword = "\(charIDStr)0\(i)"
                    hsrDB.skillRanks[keyword]?.skillAddLevelList.forEach { thisPointId, levelDelta in
                        var writeKeyArr = thisPointId.map(\.description)
                        writeKeyArr.insert("0", at: 4)
                        levelAdditionList[writeKeyArr.joined(), default: 0] += levelDelta
                    }
                }
            }

            self.basicAttack = .init(
                charIDStr: charIDStr, baseLevel: fetched[0].level,
                levelAddition: levelAdditionList[fetched[0].pointId.description],
                type: .basicAttack,
                game: .starRail
            )
            self.elementalSkill = .init(
                charIDStr: charIDStr, baseLevel: fetched[1].level,
                levelAddition: levelAdditionList[fetched[1].pointId.description],
                type: .elementalSkill,
                game: .starRail
            )
            self.elementalBurst = .init(
                charIDStr: charIDStr, baseLevel: fetched[2].level,
                levelAddition: levelAdditionList[fetched[2].pointId.description],
                type: .elementalBurst,
                game: .starRail
            )
            self.talent = .init(
                charIDStr: charIDStr, baseLevel: fetched[3].level,
                levelAddition: levelAdditionList[fetched[3].pointId.description],
                type: .talent,
                game: .starRail
            )
            self.game = .starRail
        }

        // MARK: Public

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
        // MARK: Lifecycle

        /// 该建构子不得用于圣遗物的词条构筑。
        public init(
            hsrDB: Enka.EnkaDB4HSR,
            type: Enka.PropertyType,
            value: Double
        ) {
            self.type = type
            self.value = value
            var title = (
                hsrDB.additionalLocTable[type.rawValue] ?? hsrDB.locTable[type.rawValue] ?? type.rawValue
            )
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = false
            self.count = 0
            self.step = nil
            self.game = .starRail
        }

        /// 该建构子只得用于圣遗物的词条构筑。
        public init(
            hsrDB: Enka.EnkaDB4HSR,
            type: Enka.PropertyType,
            value: Double,
            count: Int,
            step: Int?
        ) {
            self.type = type
            self.value = value
            var title = (
                hsrDB.additionalLocTable[type.rawValue] ?? hsrDB.locTable[type.rawValue] ?? type.rawValue
            )
            Self.sanitizeTitle(&title)
            self.localizedTitle = title
            self.isArtifact = true
            self.count = count
            self.step = step
            self.game = .starRail
        }

        // MARK: Public

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

        // MARK: Private

        private static func sanitizeTitle(_ title: inout String) {
            title = title.replacingOccurrences(of: "Regeneration", with: "Recharge")
            title = title.replacingOccurrences(of: "Rate", with: "%")
            title = title.replacingOccurrences(of: "Bonus", with: "+")
            title = title.replacingOccurrences(of: "Boost", with: "+")
            title = title.replacingOccurrences(of: "ダメージ", with: "傷害量")
            title = title.replacingOccurrences(of: "能量恢复", with: "元素充能")
            title = title.replacingOccurrences(of: "能量恢復", with: "元素充能")
            title = title.replacingOccurrences(of: "属性", with: "元素")
            title = title.replacingOccurrences(of: "屬性", with: "元素")
            title = title.replacingOccurrences(of: "量子元素", with: "量子")
            title = title.replacingOccurrences(of: "物理元素", with: "物理")
            title = title.replacingOccurrences(of: "虛數元素", with: "虛數")
            title = title.replacingOccurrences(of: "虚数元素", with: "虚数")
            title = title.replacingOccurrences(of: "提高", with: "增幅")
            title = title.replacingOccurrences(of: "与", with: "")
        }
    }
}

// MARK: - Enka.AvatarSummarized.WeaponPanel

extension Enka.AvatarSummarized {
    public struct WeaponPanel: Codable, Hashable {
        // MARK: Lifecycle

        public init?(
            hsrDB: Enka.EnkaDB4HSR,
            fetched: Enka.QueriedProfileHSR.Equipment
        ) {
            guard let theCommonInfo = hsrDB.weapons[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            let nameHash = theCommonInfo.equipmentName.hash.description
            self.localizedName = hsrDB.locTable[nameHash] ?? "EnkaId: \(fetched.tid)"
            self.trainedLevel = fetched.level
            self.refinement = fetched.rank
            self.basicProps = fetched.getFlat(hsrDB: hsrDB).props.compactMap { currentRecord in
                let theType = Enka.PropertyType(rawValue: currentRecord.type)
                return theType != .unknownType
                    ? PropertyPair(hsrDB: hsrDB, type: theType, value: currentRecord.value)
                    : PropertyPair?.none
            }
            self.specialProps = hsrDB.meta.equipmentSkill.query(
                id: enkaId, stage: fetched.rank
            ).map { key, value in
                PropertyPair(hsrDB: hsrDB, type: key, value: value)
            }
            self.game = .starRail
        }

        // MARK: Public

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
        // MARK: Lifecycle

        public init?(hsrDB: Enka.EnkaDB4HSR, fetched: Enka.QueriedProfileHSR.ArtifactItem) {
            guard let theCommonInfo = hsrDB.artifacts[fetched.tid.description] else { return nil }
            self.enkaId = fetched.tid
            self.commonInfo = theCommonInfo
            self.paramDataFetched = fetched
            guard let flat = fetched.getFlat(hsrDB: hsrDB) else { return nil }
            guard let matchedType = Enka.ArtifactType(typeID: paramDataFetched.type, game: .starRail)
                ?? Enka.ArtifactType(rawValue: commonInfo.type) else { return nil }
            self.type = matchedType

            let props: [PropertyPair] = flat.props.compactMap { currentRecord in
                let theType = Enka.PropertyType(rawValue: currentRecord.type)
                if theType != .unknownType {
                    return PropertyPair(
                        hsrDB: hsrDB,
                        type: theType,
                        value: currentRecord.value,
                        count: currentRecord.count,
                        step: currentRecord.step
                    )
                }
                return nil
            }
            guard let theMainProp = props.first else { return nil }
            self.mainProp = theMainProp
            self.subProps = Array(props.dropFirst())
            self.setID = flat.setID
            // 回頭恐需要單獨給聖遺物套裝名稱設定 Datamine。
            self.setNameLocalized = "Set.\(setID)"
            self.game = .starRail
        }

        // MARK: Public

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
