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
}

extension Enka.PVPair {
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

extension Enka.AvatarSummarized.WeaponPanel {
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
            guard theType != .unknownType else { return nil }
            let newValue = currentRecord.value
            return Enka.PVPair(hsrDB: hsrDB, type: theType, value: newValue)
        }
        self.specialProps = hsrDB.meta.equipmentSkill.query(
            id: enkaId, stage: fetched.rank
        ).map { key, value in
            Enka.PVPair(hsrDB: hsrDB, type: key, value: value)
        }
        self.game = .starRail
    }
}

extension Enka.AvatarSummarized.ArtifactInfo {
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

        let props: [Enka.PVPair] = flat.props.compactMap { currentRecord in
            let theType = Enka.PropertyType(rawValue: currentRecord.type)
            if theType != .unknownType {
                return Enka.PVPair(
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
}
