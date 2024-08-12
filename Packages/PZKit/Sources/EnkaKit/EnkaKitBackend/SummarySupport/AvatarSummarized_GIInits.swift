// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaDBModels

extension Enka.AvatarSummarized.AvatarMainInfo {
    // MARK: Lifecycle

    /// 原神专用建构子。
    public init?(
        giDB: Enka.EnkaDB4GI,
        charID: String,
        avatarLevel avatarLv: Int,
        constellation constellationLevel: Int,
        baseSkills baseSkillSet: BaseSkillSet,
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
        self.lifePath = .none // 原神角色没有命途的概念。
        let nameTyped = Enka.CharacterName(pidStr: charID)
        self.localizedName = nameTyped.i18n(theDB: giDB, officialNameOnly: true)
        self.localizedRealName = nameTyped.i18n(theDB: giDB, officialNameOnly: false)
        self.terms = .init(lang: giDB.locTag, game: .genshinImpact)
        self.idExpressable = idExpressible
        guard game == .genshinImpact else { return nil }
    }
}

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
    private struct GenshinSkillRawDataPair {
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
        avatar avatarInfo: Enka.QueriedProfileGI.RawAvatar
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

extension Enka.AvatarSummarized.WeaponPanel {
    // MARK: Lifecycle

    /// 原神专用建构子。
    public init?(
        giDB: Enka.EnkaDB4GI,
        avatar: Enka.QueriedProfileGI.RawAvatar
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
        self.localizedName = giDB.getTranslationFor(id: weaponPack.flat.nameTextMapHash)
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

extension Enka.AvatarSummarized.ArtifactInfo {
    // MARK: Lifecycle

    /// 原神专用建构子。
    public init?(giDB: Enka.EnkaDB4GI, equipItem: Enka.QueriedProfileGI.RawAvatar.EquipListItemRAW) {
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
            countMap = ArtifactRating.ARSputnik.shared.calculateSteps4GI(against: appendPropIDs)
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
