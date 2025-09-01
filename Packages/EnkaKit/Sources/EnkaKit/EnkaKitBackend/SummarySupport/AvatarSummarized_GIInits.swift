// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import EnkaDBModels
import PZBaseKit

// MARK: - Constructors for summarizing Enka query results.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo {
    // MARK: Lifecycle

    /// 原神专用建构子。
    public init?(
        giDB: Enka.EnkaDB4GI,
        charID: String,
        avatarLevel avatarLv: Int,
        constellation constellationLevel: Int,
        baseSkills baseSkillSet: BaseSkillSet,
        fetter: Int?,
        costumeID: String? = nil
    ) {
        guard let theCommonInfo = giDB.characters[charID] else {
            print("theCommonInfo nulled")
            return nil
        }
        guard let idExpressible = Enka.AvatarSummarized.CharacterID(id: charID, costumeID: costumeID) else {
            print("idExpressible nulled")
            return nil
        }
        guard let theElement = Enka.GameElement(rawValue: theCommonInfo.element) else {
            print("theElement nulled")
            return nil
        }
        self.avatarLevel = avatarLv
        self.constellation = constellationLevel
        self.baseSkills = baseSkillSet
        self.uniqueCharId = charID
        self.element = theElement
        let maybeLifepath = Enka.GenshinLifePathRecord.guessPath(for: charID)
        self.lifePath = maybeLifepath ?? .none // 原神角色没有命途的概念。
        let nameTyped = Enka.CharacterName(pidStr: charID)
        self.localizedName = nameTyped.i18n(theDB: giDB, officialNameOnly: true)
        self.localizedRealName = nameTyped.i18n(theDB: giDB, officialNameOnly: false)
        self.terms = .init(lang: giDB.locTag, game: .genshinImpact)
        self.idExpressable = idExpressible
        self.fetter = fetter
        if theCommonInfo.qualityType == "QUALITY_PURPLE" {
            self.rarityStars = 4
        } else {
            self.rarityStars = 5 // Both 5 stars and Aloy.
        }
        guard game == .genshinImpact else { return nil }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
    fileprivate struct GenshinSkillRawDataPair {
        // MARK: Internal

        let charID: String
        let baseLevel: Int
        let additionalLevel: Int?
        let icon: String

        func toBaseSkill(type: SkillType) -> BaseSkill {
            .init(
                charIDStr: charID,
                baseLevel: baseLevel,
                levelAddition: additionalLevel,
                type: type,
                game: .genshinImpact,
                iconAssetName: "gi_skill_\(icon.dropFirst(6))",
                iconOnlineFileNameStem: icon
            )
        }

        // MARK: Fileprivate

        fileprivate typealias SkillType = Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill.SkillType
    }

    /// 原神专用建构子。
    public init?(
        giDB: Enka.EnkaDB4GI,
        avatar avatarInfo: Enka.QueriedProfileGI.QueriedAvatar
    ) {
        guard let character = giDB.characters[avatarInfo.id] else { return nil }
        guard character.skillOrder.count == 3 else { return nil } // 原神的角色只有三个可以升级的技能。

        let concatenated: [GenshinSkillRawDataPair] = character.skillOrder.map { skillID in
            let rawLevel = avatarInfo.skillLevelMap[skillID.description] ?? 0
            let icon = character.skills[skillID.description] ?? "UI_Talent_Combine_Skill_ExtraItem"
            // 从 proudSkillExtraLevelMap 获取所有可能的天赋等级加成数据。
            var adjustedDelta = avatarInfo
                .proudSkillExtraLevelMap?[(character.proudMap[skillID.description] ?? 0).description] ?? 0
            // 对该笔天赋等级加成数据做去余处理，以图仅保留命之座天赋加成。
            adjustedDelta = adjustedDelta - adjustedDelta % 3
            return GenshinSkillRawDataPair(
                charID: avatarInfo.id,
                baseLevel: rawLevel,
                additionalLevel: adjustedDelta == 0 ? nil : adjustedDelta,
                icon: icon
            )
        }

        self.basicAttack = concatenated[0].toBaseSkill(type: .basicAttack)
        self.elementalSkill = concatenated[1].toBaseSkill(type: .elementalSkill)
        self.elementalBurst = concatenated[2].toBaseSkill(type: .elementalBurst)
        /// 原神不需要处理星穹铁道的天赋。这里伪造一个，回头让前端根据游戏类型判断是否显示天赋。
        self.talent = .init(
            charIDStr: avatarInfo.id, baseLevel: 114,
            levelAddition: 514,
            type: .talent,
            game: .genshinImpact,
            iconAssetName: "YJSNPI",
            iconOnlineFileNameStem: "YJSNPI"
        )
        self.game = .genshinImpact
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.WeaponPanel {
    // MARK: Lifecycle

    /// 原神专用建构子。
    public init?(
        giDB: Enka.EnkaDB4GI,
        avatar: Enka.QueriedProfileGI.QueriedAvatar
    ) {
        /// 武器的 flat.equipType 必定为 nil，因为这个属性是用来鉴定圣遗物部位分类的。
        let weaponPack = avatar.equipList.first {
            $0.flat.itemType == "ITEM_WEAPON" || $0.flat.equipType == nil
        }
        guard let weaponPack, let weapon = weaponPack.weapon,
              let weaponStats = weaponPack.flat.weaponStats
        else { return nil } /// 原神的角色必定有至少装备一个武器。
        self.weaponID = weaponPack.itemId
        self.rarityStars = weaponPack.flat.rankLevel
        self.localizedName = giDB.getFailableTranslationFor(id: weaponPack.itemId.description)
            ?? giDB.getTranslationFor(id: weaponPack.flat.nameTextMapHash)
        self.trainedLevel = weapon.level
        self.refinement = (weapon.affixMap?.first?.value ?? 0) + 1
        var arrMainProps = [Enka.PVPair]()
        var arrSubProps = [Enka.PVPair]()
        weaponStats.forEach { currentStat in
            let type = currentStat.appendPropId
            let propValue: Double = type.isPercentage
                ? (currentStat.statValue / 100)
                : currentStat.statValue
            let newProp = Enka.PVPair(theDB: giDB, type: type, value: propValue)
            switch type {
            case .baseAttack:
                arrMainProps.append(newProp)
            default:
                arrSubProps.append(newProp)
            }
        }
        self.iconOnlineFileNameStem = weaponPack.flat.icon
        self.iconAssetName = "gi_weapon_\(weaponID)"
        self.basicProps = arrMainProps
        self.specialProps = arrSubProps
        self.game = .genshinImpact
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.ArtifactInfo {
    // MARK: Lifecycle

    /// 原神专用建构子。
    @MainActor
    public init?(giDB: Enka.EnkaDB4GI, equipItem: Enka.QueriedProfileGI.QueriedAvatar.EquipListItemRAW) {
        guard let equipTypeStr = equipItem.flat.equipType,
              let artifactType = Enka.ArtifactType(rawValue: equipTypeStr),
              equipItem.flat.itemType != "ITEM_WEAPON",
              let artifactDataObj = equipItem.reliquary,
              let mainStat = equipItem.flat.reliquaryMainstat
        else { return nil }

        /// 必须能判断 SetID，否则抛 nil。
        let arr = equipItem.flat.icon.split(separator: "_")
        let setID: Int? = arr.count == 4 ? Int(arr[2]) : nil
        guard let setID else { return nil }

        self.itemID = equipItem.itemId
        self.rarityStars = equipItem.flat.rankLevel
        self.trainedLevel = Swift.max(0, artifactDataObj.level - 1) // 待检查。
        self.type = artifactType

        let mainPropValue: Double = mainStat.mainPropId.isPercentage
            ? (mainStat.statValue / 100)
            : mainStat.statValue
        self.mainProp = .init(
            theDB: giDB,
            type: mainStat.mainPropId,
            value: mainPropValue,
            count: -114_514, // Main Prop has no counts.
            step: nil // Not necessary for Main Prop. Use artifact promote level instead.
        )

        var arrSubProps = [Enka.PVPair]()

        var countMap: [Enka.PropertyType: Int] = [:]
        if let appendPropIDs = artifactDataObj.appendPropIdList {
            countMap = ArtifactRating.ARSputnik.shared.calculateCounts4GI(against: appendPropIDs)
        }

        equipItem.flat.reliquarySubstats?.forEach { currentRecord in
            guard currentRecord.appendPropId != .unknownType else { return }
            let subPropValue: Double = currentRecord.appendPropId.isPercentage
                ? (currentRecord.statValue / 100)
                : currentRecord.statValue
            arrSubProps.append(
                .init(
                    theDB: giDB,
                    type: currentRecord.appendPropId,
                    value: subPropValue,
                    count: countMap[currentRecord.appendPropId] ?? -114_514,
                    step: Int((Double(artifactDataObj.level) / 4).rounded(.down))
                )
            )
        }
        self.subProps = arrSubProps
        self.setID = setID
        self.iconOnlineFileNameStem = equipItem.flat.icon
        var iconAssetNameStr = "gi_relic_"
        iconAssetNameStr += equipItem.flat.icon.replacingOccurrences(of: "UI_RelicIcon_", with: "")
        self.iconAssetName = iconAssetNameStr
        var setName = "Set.\(setID)"
        if let hash = equipItem.flat.setNameTextMapHash {
            setName = giDB.getTranslationFor(id: hash.description)
        }
        self.setNameLocalized = setName
        self.game = .genshinImpact
    }
}

// MARK: - Constructors for summarizing HoYoLAB query results.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo {
    public init?(
        giDB: Enka.EnkaDB4GI,
        hylRAW: HYQueriedModels.HYLAvatarDetail4GI
    ) {
        let costumeID = hylRAW.costumes.first?.id.description
        guard let theElement = Enka.GameElement(rawValue: hylRAW.base.element) else {
            print("theElement nulled")
            return nil
        }
        guard var idExpressible = Enka.AvatarSummarized.CharacterID(id: hylRAW.avatarIdStr, costumeID: costumeID) else {
            print("idExpressible nulled")
            return nil
        }
        let skillDepotIDSuffix: String = {
            let depotID = idExpressible.nameObj.getGenshinProtagonistSkillDepotID(element: theElement)
            guard let depotID else { return "" }
            return "-\(depotID)"
        }()
        let charID = hylRAW.avatarIdStr + skillDepotIDSuffix
        if !skillDepotIDSuffix.isEmpty {
            // Update the idExpressible for Protagonist.
            guard let idExpressibleNEO = Enka.AvatarSummarized.CharacterID(id: charID, costumeID: costumeID) else {
                print("idExpressible nulled")
                return nil
            }
            idExpressible = idExpressibleNEO
        }
        guard let baseSkillSet = Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet(
            giDB: giDB,
            hylRAW: hylRAW,
            charID: charID
        ) else {
            print("baseSkillSet nulled")
            return nil
        }
        self.avatarLevel = hylRAW.base.level
        self.constellation = hylRAW.constellations.map(\.isActived).reduce(0) { $1 ? $0 + 1 : $0 }
        self.baseSkills = baseSkillSet
        self.uniqueCharId = charID
        self.element = theElement
        let maybeLifepath = Enka.GenshinLifePathRecord.guessPath(for: charID)
        self.lifePath = maybeLifepath ?? .none // 原神角色没有命途的概念。
        let nameTyped = Enka.CharacterName(pidStr: charID)
        self.localizedName = nameTyped.i18n(theDB: giDB, officialNameOnly: true)
        self.localizedRealName = nameTyped.i18n(theDB: giDB, officialNameOnly: false)
        self.terms = .init(lang: giDB.locTag, game: .genshinImpact)
        self.idExpressable = idExpressible
        self.rarityStars = hylRAW.base.rarity
        self.fetter = hylRAW.base.fetter
        guard game == .genshinImpact else { return nil }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
    fileprivate init?(
        giDB: Enka.EnkaDB4GI,
        hylRAW: HYQueriedModels.HYLAvatarDetail4GI,
        charID: String
    ) {
        guard let character = giDB.characters[charID] else {
            print("theCommonInfo nulled")
            return nil
        }
        guard character.skillOrder.count == 3 else { return nil } // 原神的角色只有三个可以升级的技能。
        var skillLevelMap = [String: Int]()
        hylRAW.skills.forEach { skillUnit in
            skillLevelMap[skillUnit.skillID.description] = skillUnit.level
        }
        let concatenated: [GenshinSkillRawDataPair] = character.skillOrder.map { skillID in
            let rawLevel = skillLevelMap[skillID.description] ?? 0 // 已计入命之座天赋等级加成。
            let icon = character.skills[skillID.description] ?? "UI_Talent_Combine_Skill_ExtraItem"
            return GenshinSkillRawDataPair(
                charID: charID,
                baseLevel: rawLevel,
                additionalLevel: nil, // HoYoLAB 的查询结果无法将角色技能基础等级与命座天赋等级加成分割开。
                icon: icon
            )
        }
        self.basicAttack = concatenated[0].toBaseSkill(type: .basicAttack)
        self.elementalSkill = concatenated[1].toBaseSkill(type: .elementalSkill)
        self.elementalBurst = concatenated[2].toBaseSkill(type: .elementalBurst)
        /// 原神不需要处理星穹铁道的天赋。这里伪造一个，回头让前端根据游戏类型判断是否显示天赋。
        self.talent = .init(
            charIDStr: charID, baseLevel: 114,
            levelAddition: 514,
            type: .talent,
            game: .genshinImpact,
            iconAssetName: "YJSNPI",
            iconOnlineFileNameStem: "YJSNPI"
        )
        self.game = .genshinImpact
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.WeaponPanel {
    public init?(
        giDB: Enka.EnkaDB4GI,
        hylRAW: HYQueriedModels.HYLAvatarDetail4GI
    ) {
        let weaponRaw = hylRAW.weapon
        self.weaponID = weaponRaw.id
        self.rarityStars = weaponRaw.rarity
        self.localizedName = giDB.getFailableTranslationFor(
            id: weaponRaw.id.description
        ) ?? weaponRaw.name
        self.trainedLevel = weaponRaw.level
        self.refinement = weaponRaw.affixLevel
        self.iconOnlineFileNameStem = weaponRaw.icon // 假数值，基本上用不到
        self.iconAssetName = "gi_weapon_\(weaponID)"
        self.basicProps = [
            Enka.PVPair(
                theDB: giDB,
                type: .init(hoyoPropID4GI: weaponRaw.mainProperty.propertyType),
                valueStr: weaponRaw.mainProperty.propertyFinal
            ),
        ].compactMap { $0 }
        self.specialProps = [
            Enka.PVPair(
                theDB: giDB,
                type: .init(hoyoPropID4GI: weaponRaw.subProperty?.propertyType ?? -114514),
                valueStr: weaponRaw.subProperty?.propertyFinal ?? "-114514"
            ),
        ].compactMap { $0 }
        guard !basicProps.isEmpty else { return nil } // 原神武器必须有主词条。
        self.game = .genshinImpact
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.ArtifactInfo {
    public init?(
        giDB: Enka.EnkaDB4GI,
        hylArtifactRAW: HYQueriedModels.HYLAvatarDetail4GI.Relic
    ) {
        let setID = Self.dropDigits4GI(from: hylArtifactRAW.relicSet.id)
        guard let setID else { return nil }
        let posType = Enka.ArtifactType(typeID: hylArtifactRAW.pos, game: .genshinImpact)
        guard let posType else { return nil }
        self.itemID = hylArtifactRAW.id
        self.rarityStars = hylArtifactRAW.rarity
        self.trainedLevel = hylArtifactRAW.level
        self.type = posType
        self.setID = setID
        self.iconOnlineFileNameStem = hylArtifactRAW.icon
        self.iconAssetName = "gi_relic_\(setID)_\(posType.assetSuffix)"
        self.setNameLocalized = hylArtifactRAW.relicSet.name
        let mainProp = Enka.PVPair(
            theDB: giDB,
            type: .init(hoyoPropID4GI: hylArtifactRAW.mainProperty.propertyType),
            valueStr: hylArtifactRAW.mainProperty.value,
            count: -114_514, // Main Prop has no counts.
            step: nil // Not necessary for Main Prop. Use artifact promote level instead.
        )
        guard let mainProp else { return nil }
        self.mainProp = mainProp
        self.subProps = hylArtifactRAW.subPropertyList.compactMap { subPropRAW in
            Enka.PVPair(
                theDB: giDB,
                type: .init(hoyoPropID4GI: subPropRAW.propertyType),
                valueStr: subPropRAW.value,
                count: subPropRAW.times + 1,
                step: Int((Double(hylArtifactRAW.level) / 4).rounded(.down))
            )
        }
        self.game = .genshinImpact
    }

    private static func dropDigits4GI(from number: Int) -> Int? {
        let digits = String(number).compactMap(\.description)
        guard digits.count > 6 else { return nil }
        let filteredDigits = [digits[1], digits[2], digits[3], digits[4], digits[5]].reduce([], +)
        let resultString = String(filteredDigits)
        return Int(resultString)
    }
}
