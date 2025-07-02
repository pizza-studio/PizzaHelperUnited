// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaDBModels

// MARK: - Constructors for summarizing Enka query results.

extension Enka.AvatarSummarized.AvatarMainInfo {
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
        self.uniqueCharId = charID.description
        self.element = theElement
        self.lifePath = lifePath
        let nameTyped = Enka.CharacterName(pid: charID)
        self.localizedName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: true)
        self.localizedRealName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: false)
        self.terms = .init(lang: hsrDB.locTag, game: .starRail)
        self.idExpressable = idExpressible
        self.rarityStars = theCommonInfo.rarity
        self.fetter = nil
        guard game == .starRail else { return nil }
    }
}

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
    /// 星穹铁道专用建构子。
    public init?(
        hsrDB: Enka.EnkaDB4HSR,
        constellation: Int,
        charID: Int,
        fetched: [Enka.QueriedProfileHSR.SkillTreeItem]
    ) {
        guard fetched.count >= 4 else { return nil }
        var charID = charID
        /// 主角龙凤胎共用男方「穹」的技能图案。
        if case .ofStelle = Protagonist(rawValue: charID) { charID -= 1 }
        let charIDStr = charID.description
        var levelAdditionList = [String: Int]()
        if constellation > 1 {
            for i in 1 ... constellation {
                let keyword = "\(charIDStr)0\(i)"
                hsrDB.skillRanks[keyword]?.skillAddLevelList.forEach { thisPointID, levelDelta in
                    var writeKeyArr = thisPointID.map(\.description)
                    writeKeyArr.insert("0", at: 4)
                    levelAdditionList[writeKeyArr.joined(), default: 0] += levelDelta
                }
            }
        }

        func getTypeRaw(_ type: Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill.SkillType) -> String {
            type.rawValue
        }

        let offlineAssetPrefix = "hsr_skill_\(charIDStr)"
        let onlineFilePrefix = "SkillIcon_\(charIDStr)"

        self.basicAttack = .init(
            charIDStr: charIDStr, baseLevel: fetched[0].level,
            levelAddition: levelAdditionList[fetched[0].pointId.description],
            type: .basicAttack,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.basicAttack))",
            iconOnlineFileNameStem: "\(onlineFilePrefix)_\(getTypeRaw(.basicAttack))"
        )
        self.elementalSkill = .init(
            charIDStr: charIDStr, baseLevel: fetched[1].level,
            levelAddition: levelAdditionList[fetched[1].pointId.description],
            type: .elementalSkill,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.elementalSkill))",
            iconOnlineFileNameStem: "\(onlineFilePrefix)_\(getTypeRaw(.elementalSkill))"
        )
        self.elementalBurst = .init(
            charIDStr: charIDStr, baseLevel: fetched[2].level,
            levelAddition: levelAdditionList[fetched[2].pointId.description],
            type: .elementalBurst,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.elementalBurst))",
            iconOnlineFileNameStem: "\(onlineFilePrefix)_\(getTypeRaw(.elementalBurst))"
        )
        self.talent = .init(
            charIDStr: charIDStr, baseLevel: fetched[3].level,
            levelAddition: levelAdditionList[fetched[3].pointId.description],
            type: .talent,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.talent))",
            iconOnlineFileNameStem: "\(onlineFilePrefix)_\(getTypeRaw(.talent))"
        )
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.WeaponPanel {
    // MARK: Lifecycle

    /// 星穹铁道专用建构子。
    public init?(
        hsrDB: Enka.EnkaDB4HSR,
        fetched: Enka.QueriedProfileHSR.Equipment
    ) {
        guard let theCommonInfo = hsrDB.weapons[fetched.tid.description] else { return nil }
        self.weaponID = fetched.tid
        let nameHash = theCommonInfo.equipmentName.hash.description
        self.localizedName = hsrDB.locTable[nameHash] ?? "EnkaId: \(fetched.tid)"
        self.trainedLevel = fetched.level
        self.refinement = fetched.rank
        self.basicProps = fetched.getFlat(hsrDB: hsrDB).props.compactMap { currentRecord in
            let theType = Enka.PropertyType(rawValue: currentRecord.type)
            guard theType != .unknownType else { return nil }
            let newValue = currentRecord.value
            return Enka.PVPair(theDB: hsrDB, type: theType, value: newValue)
        }
        self.specialProps = hsrDB.meta.equipmentSkill.query(
            id: weaponID, stage: fetched.rank
        ).map { key, value in
            Enka.PVPair(theDB: hsrDB, type: key, value: value)
        }
        self.iconOnlineFileNameStem = theCommonInfo
            .imagePath.split(separator: "/").suffix(1).joined().dropLast(4).description
        self.iconAssetName = "hsr_light_cone_\(weaponID)"
        self.rarityStars = theCommonInfo.rarity
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.ArtifactInfo {
    // MARK: Lifecycle

    /// 星穹铁道专用建构子。
    public init?(hsrDB: Enka.EnkaDB4HSR, fetched: Enka.QueriedProfileHSR.ArtifactItem) {
        guard let theCommonInfo = hsrDB.artifacts[fetched.tid.description] else { return nil }
        self.itemID = fetched.tid
        self.rarityStars = theCommonInfo.rarity
        self.trainedLevel = fetched.level ?? 0
        guard let flat = fetched.getFlat(hsrDB: hsrDB) else { return nil }
        guard let matchedType = Enka.ArtifactType(typeID: fetched.type, game: .starRail)
            ?? Enka.ArtifactType(rawValue: theCommonInfo.type) else { return nil }
        self.type = matchedType

        guard let firstRawProp = flat.props.first else { return nil }

        let theMainProp = Enka.PVPair(
            theDB: hsrDB,
            type: Enka.PropertyType(rawValue: firstRawProp.type),
            value: firstRawProp.value,
            count: firstRawProp.count,
            step: nil // Not necessary for Main Prop. Use artifact promote level instead.
        )

        let theSubProps: [Enka.PVPair] = flat.props.dropFirst().compactMap { currentRecord in
            let result = Enka.PVPair(
                theDB: hsrDB,
                type: Enka.PropertyType(rawValue: currentRecord.type),
                value: currentRecord.value,
                count: currentRecord.count,
                step: Int((Double(fetched.level ?? 0) / 3).rounded(.down))
            )
            return result
        }
        self.mainProp = theMainProp
        self.subProps = theSubProps
        self.setID = flat.setID
        // 回頭恐需要單獨給聖遺物套裝名稱設定 Datamine。
        self.setNameLocalized = "Set.\(setID)"
        self.iconOnlineFileNameStem = theCommonInfo
            .icon.split(separator: "/").suffix(1).joined().dropLast(4).description
        self.iconAssetName = "hsr_relic_\(setID)_\(type.assetSuffix)"
        self.game = .starRail
    }
}

// MARK: - Constructors for summarizing HoYoLAB query results.

extension Enka.AvatarSummarized.AvatarMainInfo {
    public init?(hsrDB: Enka.EnkaDB4HSR, hylRAW: HYQueriedModels.HYLAvatarDetail4HSR) {
        let charIDStr = hylRAW.avatarIdStr
        guard let theCommonInfo = hsrDB.characters[charIDStr] else { return nil }
        guard let idExpressible = Enka.AvatarSummarized.CharacterID(id: charIDStr) else { return nil }
        guard let lifePath = Enka.LifePath(rawValue: theCommonInfo.avatarBaseType) else { return nil }
        guard let theElement = Enka.GameElement(rawValue: theCommonInfo.element) else { return nil }
        guard let baseSkillSet = Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet(
            hsrDB: hsrDB,
            hylRAW: hylRAW
        ) else {
            print("baseSkillSet nulled")
            return nil
        }
        self.avatarLevel = hylRAW.level
        self.constellation = hylRAW.eidolonResonanceList.map(\.isUnlocked).reduce(0) { $1 ? $0 + 1 : $0 }
        self.baseSkills = baseSkillSet
        self.uniqueCharId = charIDStr
        self.element = theElement
        self.lifePath = lifePath
        let nameTyped = Enka.CharacterName(pid: hylRAW.id)
        self.localizedName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: true)
        self.localizedRealName = nameTyped.i18n(theDB: hsrDB, officialNameOnly: false)
        self.terms = .init(lang: hsrDB.locTag, game: .starRail)
        self.idExpressable = idExpressible
        self.rarityStars = theCommonInfo.rarity
        self.fetter = nil
        guard game == .starRail else { return nil }
    }
}

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
    public init?(hsrDB: Enka.EnkaDB4HSR, hylRAW: HYQueriedModels.HYLAvatarDetail4HSR) {
        var charID = hylRAW.id
        if case .ofStelle = Protagonist(rawValue: charID) { charID -= 1 }
        let charIDStr = charID.description
        let skillsRAW = hylRAW.skills.prefix(4)
        guard skillsRAW.count == 4 else { return nil }
        let eidolonResonance: Int = hylRAW.eidolonResonanceList.map(\.isUnlocked).reduce(0) {
            $1 ? $0 + 1 : 0
        }

        var levelAdditionList = [String: Int]()
        if eidolonResonance > 1 {
            for i in 1 ... eidolonResonance {
                let keyword = "\(charIDStr)0\(i)"
                hsrDB.skillRanks[keyword]?.skillAddLevelList.forEach { thisPointID, levelDelta in
                    var writeKeyArr = thisPointID.map(\.description)
                    writeKeyArr.insert("0", at: 4)
                    levelAdditionList[writeKeyArr.joined(), default: 0] += levelDelta
                }
            }
        }

        let offlineAssetPrefix = "hsr_skill_\(charIDStr)"

        func getTypeRaw(_ type: Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill.SkillType) -> String {
            type.rawValue
        }

        self.basicAttack = .init(
            charIDStr: charIDStr, summedLevel: skillsRAW[0].level,
            levelAddition: levelAdditionList[skillsRAW[0].pointID],
            type: .basicAttack,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.basicAttack))",
            iconOnlineFileNameStem: skillsRAW[0].itemURL
        )
        self.elementalSkill = .init(
            charIDStr: charIDStr, summedLevel: skillsRAW[1].level,
            levelAddition: levelAdditionList[skillsRAW[1].pointID],
            type: .elementalSkill,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.elementalSkill))",
            iconOnlineFileNameStem: skillsRAW[1].itemURL
        )
        self.elementalBurst = .init(
            charIDStr: charIDStr, summedLevel: skillsRAW[2].level,
            levelAddition: levelAdditionList[skillsRAW[2].pointID],
            type: .elementalBurst,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.elementalBurst))",
            iconOnlineFileNameStem: skillsRAW[2].itemURL
        )
        self.talent = .init(
            charIDStr: charIDStr, summedLevel: skillsRAW[3].level,
            levelAddition: levelAdditionList[skillsRAW[3].pointID],
            type: .talent,
            game: .starRail,
            iconAssetName: "\(offlineAssetPrefix)_\(getTypeRaw(.talent))",
            iconOnlineFileNameStem: skillsRAW[3].itemURL
        )
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.WeaponPanel {
    public init?(hsrDB: Enka.EnkaDB4HSR, hylRAW: HYQueriedModels.HYLAvatarDetail4HSR) {
        guard let weaponRAW = hylRAW.equip else { return nil }
        guard let theCommonInfo = hsrDB.weapons[weaponRAW.id.description] else { return nil }
        self.weaponID = weaponRAW.id
        let nameHash = theCommonInfo.equipmentName.hash.description
        self.localizedName = hsrDB.locTable[nameHash] ?? "EnkaId: \(weaponID)"
        self.trainedLevel = weaponRAW.level
        self.refinement = weaponRAW.rank
        /// 米游社面板的武器不包含主副词条资讯。
        self.basicProps = weaponRAW.getFlat(hsrDB: hsrDB).props.compactMap { currentRecord in
            let theType = Enka.PropertyType(rawValue: currentRecord.type)
            guard theType != .unknownType else { return nil }
            let newValue = currentRecord.value
            return Enka.PVPair(theDB: hsrDB, type: theType, value: newValue)
        }
        self.specialProps = hsrDB.meta.equipmentSkill.query(
            id: weaponID, stage: weaponRAW.rank
        ).map { key, value in
            Enka.PVPair(theDB: hsrDB, type: key, value: value)
        }
        self.iconOnlineFileNameStem = weaponRAW.icon
        self.iconAssetName = "hsr_light_cone_\(weaponID)"
        self.rarityStars = theCommonInfo.rarity
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.ArtifactInfo {
    public init?(
        hsrDB: Enka.EnkaDB4HSR,
        hylArtifactRAW: HYQueriedModels.HYLAvatarDetail4HSR.Relic
    ) {
        guard let theCommonInfo = hsrDB.artifacts[hylArtifactRAW.id.description] else { return nil }
        let relicType = Enka.ArtifactType(typeID: hylArtifactRAW.pos, game: .starRail) ?? Enka
            .ArtifactType(rawValue: theCommonInfo.type)
        guard let relicType else { return nil }
        let mainProp = Enka.PVPair(
            theDB: hsrDB,
            type: .init(hoyoPropID4HSR: hylArtifactRAW.mainProperty.propertyType),
            valueStr: hylArtifactRAW.mainProperty.value,
            count: hylArtifactRAW.mainProperty.times,
            step: nil // Not necessary for Main Prop. Use artifact promote level instead.
        )
        guard let mainProp else { return nil }
        let setID = Self.dropDigits4HSR(from: hylArtifactRAW.id)
        guard let setID else { return nil }
        self.setID = setID
        self.setNameLocalized = "Set.\(setID)"
        self.itemID = hylArtifactRAW.id
        self.rarityStars = theCommonInfo.rarity
        self.trainedLevel = hylArtifactRAW.level
        self.type = relicType
        self.iconOnlineFileNameStem = hylArtifactRAW.icon
        self.iconAssetName = "hsr_relic_\(setID)_\(type.assetSuffix)"
        self.game = .starRail
        self.mainProp = mainProp
        self.subProps = hylArtifactRAW.properties.compactMap { rawProp in
            let result = Enka.PVPair(
                theDB: hsrDB,
                type: .init(hoyoPropID4HSR: rawProp.propertyType),
                valueStr: rawProp.value,
                count: rawProp.times,
                step: Int((Double(hylArtifactRAW.level) / 3).rounded(.down))
            )
            return result
        }
    }

    private static func dropDigits4HSR(from number: Int) -> Int? {
        let digits = String(number).compactMap(\.description)
        guard digits.count > 4 else { return nil }
        let filteredDigits = [digits[1], digits[2], digits[3]].reduce([], +)
        let resultString = String(filteredDigits)
        return Int(resultString)
    }
}
