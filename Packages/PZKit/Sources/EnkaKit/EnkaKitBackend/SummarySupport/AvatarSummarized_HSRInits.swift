// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaDBModels

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
        guard game == .starRail else { return nil }
    }
}

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet {
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

        func getTypeRaw(_ type: Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill.SkillType) -> String {
            type.rawValue
        }

        self.basicAttack = .init(
            charIDStr: charIDStr, baseLevel: fetched[0].level,
            levelAddition: levelAdditionList[fetched[0].pointId.description],
            type: .basicAttack,
            game: .starRail,
            iconFileNameStem: "\(charIDStr)_\(getTypeRaw(.basicAttack))"
        )
        self.elementalSkill = .init(
            charIDStr: charIDStr, baseLevel: fetched[1].level,
            levelAddition: levelAdditionList[fetched[1].pointId.description],
            type: .elementalSkill,
            game: .starRail,
            iconFileNameStem: "\(charIDStr)_\(getTypeRaw(.elementalSkill))"
        )
        self.elementalBurst = .init(
            charIDStr: charIDStr, baseLevel: fetched[2].level,
            levelAddition: levelAdditionList[fetched[2].pointId.description],
            type: .elementalBurst,
            game: .starRail,
            iconFileNameStem: "\(charIDStr)_\(getTypeRaw(.elementalBurst))"
        )
        self.talent = .init(
            charIDStr: charIDStr, baseLevel: fetched[3].level,
            levelAddition: levelAdditionList[fetched[3].pointId.description],
            type: .talent,
            game: .starRail,
            iconFileNameStem: "\(charIDStr)_\(getTypeRaw(.talent))"
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
        self.enkaId = fetched.tid
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
            id: enkaId, stage: fetched.rank
        ).map { key, value in
            Enka.PVPair(theDB: hsrDB, type: key, value: value)
        }
        self.iconOnlineFileNameStem = theCommonInfo
            .imagePath.split(separator: "/").suffix(1).joined().dropLast(4).description
        self.rarityStars = theCommonInfo.rarity
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.ArtifactInfo {
    // MARK: Lifecycle

    /// 星穹铁道专用建构子。
    public init?(hsrDB: Enka.EnkaDB4HSR, fetched: Enka.QueriedProfileHSR.ArtifactItem) {
        guard let theCommonInfo = hsrDB.artifacts[fetched.tid.description] else { return nil }
        self.enkaId = fetched.tid
        self.rarityStars = theCommonInfo.rarity
        self.trainedLevel = fetched.level ?? 0
        guard let flat = fetched.getFlat(hsrDB: hsrDB) else { return nil }
        guard let matchedType = Enka.ArtifactType(typeID: fetched.type, game: .starRail)
            ?? Enka.ArtifactType(rawValue: theCommonInfo.type) else { return nil }
        self.type = matchedType

        let props: [Enka.PVPair] = flat.props.compactMap { currentRecord in
            let theType = Enka.PropertyType(rawValue: currentRecord.type)
            if theType != .unknownType {
                return Enka.PVPair(
                    theDB: hsrDB,
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
        self.iconOnlineFileNameStem = theCommonInfo
            .icon.split(separator: "/").suffix(1).joined().dropLast(4).description
        self.game = .starRail
    }
}
