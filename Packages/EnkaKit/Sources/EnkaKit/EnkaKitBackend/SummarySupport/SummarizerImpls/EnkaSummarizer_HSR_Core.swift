// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.QueriedProfileHSR.QueriedAvatar {
    /// 计算角色面板（星穹铁道）。
    @MainActor
    public func summarize(theDB: DBType) -> Enka.AvatarSummarized? {
        // Main Info
        let baseSkillSet = Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet(
            hsrDB: theDB,
            constellation: rank ?? 0,
            charID: avatarId,
            fetched: skillTreeList
        )
        guard let baseSkillSet = baseSkillSet else { return nil }

        let mainInfo = Enka.AvatarSummarized.AvatarMainInfo(
            hsrDB: theDB,
            charID: avatarId,
            avatarLevel: level,
            constellation: rank ?? 0,
            baseSkills: baseSkillSet
        )
        guard let mainInfo = mainInfo else { return nil }

        let equipInfo: Enka.AvatarSummarized.WeaponPanel? = {
            guard let equipment = equipment else { return nil }
            return Enka.AvatarSummarized.WeaponPanel(hsrDB: theDB, fetched: equipment)
        }()

        let artifactsInfo: [Enka.AvatarSummarized.ArtifactInfo] = artifactList.compactMap {
            Enka.AvatarSummarized.ArtifactInfo(hsrDB: theDB, fetched: $0)
        }

        // Panel: Add basic values from catched character Metadata.
        let baseMetaCharacter: EnkaDBModelsHSR.Meta.AvatarMeta? = theDB.meta
            .avatar[avatarId.description]?[promotion.description]
        guard let baseMetaCharacter = baseMetaCharacter else { return nil }
        var panel = MutableAvatarPropertyPanel(game: .starRail)
        panel.maxHP = baseMetaCharacter.hpBase
        panel.attack = baseMetaCharacter.attackBase
        panel.defence = baseMetaCharacter.defenceBase
        panel.maxHP += baseMetaCharacter.hpAdd * Double(level - 1)
        panel.attack += baseMetaCharacter.attackAdd * Double(level - 1)
        panel.defence += baseMetaCharacter.defenceAdd * Double(level - 1)
        panel.speed = baseMetaCharacter.speedBase
        panel.criticalChance = baseMetaCharacter.criticalChance
        panel.criticalDamage = baseMetaCharacter.criticalDamage

        // Panel: Base Props from the Weapon.

        Self.updateFlat(for: &panel, flat: equipment?.getFlat(hsrDB: theDB))

        // Panel: Handle all additional props

        // Panel: - Additional Props from the Weapon.

        let weaponSpecialProps: [Enka.PVPair] = equipInfo?.specialProps ?? []

        // Panel: Base and Additional Props from the Skill Tree.

        let skillTreeProps: [Enka.PVPair] = skillTreeList.compactMap { currentNode in
            if currentNode.level == 1 {
                let result: [Enka.PVPair] = theDB.meta.tree
                    .query(id: currentNode.pointId, stage: 1).map {
                        Enka.PVPair(theDB: theDB, type: $0.key, value: $0.value)
                    }
                return result
            }
            return nil
        }.reduce([], +)

        // Panel: - Additional Props from the Artifacts.

        let artifactProps: [Enka.PVPair] = artifactsInfo.map(\.allProps).reduce([], +)

        // Panel: - Additional Props from the Artifact Set Effects.

        let artifactSetProps: [Enka.PVPair] = {
            var resultPairs = [Enka.PVPair]()
            var setIDCounters: [Int: Int] = [:]
            artifactsInfo.map(\.setID).forEach { setIDCounters[$0, default: 0] += 1 }
            setIDCounters.forEach { setId, count in
                guard count >= 2 else { return }
                let x: [Enka.PVPair] = theDB.meta.relic.setSkill.query(id: setId, stage: 2).map {
                    Enka.PVPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: x)
                guard count >= 4 else { return }
                let y: [Enka.PVPair] = theDB.meta.relic.setSkill.query(id: setId, stage: 4).map {
                    Enka.PVPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: y)
            }
            return resultPairs
        }()

        // Panel: Triage and Handle.

        let allProps: [Enka.PVPair] = skillTreeProps + weaponSpecialProps + artifactProps + artifactSetProps
        panel.triageAndHandle(theDB: theDB, allProps, element: mainInfo.element)

        // Panel: Final Output.

        let propPair = panel.converted(theDB: theDB, element: mainInfo.element)

        return Enka.AvatarSummarized(
            game: .starRail,
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarPropertiesA: propPair.0,
            avatarPropertiesB: propPair.1,
            artifacts: artifactsInfo,
            isEnka: true
        ).artifactsRated()
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.QueriedProfileHSR.QueriedAvatar {
    private static func updateFlat(
        for panel: inout MutableAvatarPropertyPanel,
        flat: Enka.QueriedProfileHSR.EquipmentFlat?
    ) {
        guard let equipFlat = flat else { return }
        panel.maxHP += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseHP }?.value ?? 0
        panel.attack += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseAttack }?.value ?? 0
        panel.defence += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseDefence }?
            .value ?? 0
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.QueriedProfileHSR.ArtifactItem {
    public func getFlat(hsrDB: Enka.EnkaDB4HSR) -> Enka.QueriedProfileHSR.ArtifactItem.SteppedFlat? {
        var result = [Enka.QueriedProfileHSR.PropStepped]()
        guard let matchedArtifact = hsrDB.artifacts[tid.description] else { return nil }
        let mainAffix = hsrDB.meta.relic.mainAffix[
            matchedArtifact.mainAffixGroup.description
        ]?[mainAffixId.description]
        if let mainAffix = mainAffix {
            result.append(
                .init(
                    type: mainAffix.property,
                    value: mainAffix.baseValue + mainAffix.levelAdd * Double(level ?? 0),
                    count: 0,
                    step: nil
                )
            )
        }
        subAffixList?.forEach { sub in
            guard let subAffix = hsrDB.meta.relic.subAffix[
                matchedArtifact.subAffixGroup.description
            ]?[sub.affixId.description] else { return }
            result.append(
                .init(
                    type: subAffix.property,
                    value: subAffix.baseValue * Double(sub.cnt) + subAffix.stepValue * Double(sub.step ?? 0),
                    count: sub.cnt,
                    step: sub.step ?? 0
                )
            )
        }
        return .init(
            props: result,
            setName: matchedArtifact.setID,
            setID: matchedArtifact.setID
        )
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.QueriedProfileHSR.Equipment {
    public func getFlat(hsrDB: Enka.EnkaDB4HSR) -> Enka.QueriedProfileHSR.EquipmentFlat {
        var result = [Enka.QueriedProfileHSR.Prop]()
        if let table = hsrDB.meta.equipment[tid.description]?[(promotion ?? 0).description] {
            let summedHP = table.baseHP + table.hpAdd * (Double(level) - 1)
            let summedATK = table.baseAttack + table.attackAdd * (Double(level) - 1)
            let summedDEF = table.baseDefence + table.defenceAdd * (Double(level) - 1)
            result.append(.init(type: Enka.PropertyType.baseHP.rawValue, value: summedHP))
            result.append(.init(type: Enka.PropertyType.baseAttack.rawValue, value: summedATK))
            result.append(.init(type: Enka.PropertyType.baseDefence.rawValue, value: summedDEF))
        }
        return .init(
            props: result,
            name: hsrDB.weapons[tid.description]?.equipmentName.hash ?? "-114514"
        )
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HYQueriedModels.HYLAvatarDetail4HSR.Equip {
    public func getFlat(hsrDB: Enka.EnkaDB4HSR) -> Enka.QueriedProfileHSR.EquipmentFlat {
        var result = [Enka.QueriedProfileHSR.Prop]()
        // 米游社面板原始返回结果并没有 Promotion 资讯，只能用等级来推算。推算结果可能会有一些误差。
        let promotion = switch level {
        case 71...: 6
        case 61 ... 70: 5
        case 51 ... 60: 4
        case 41 ... 50: 3
        case 31 ... 40: 2
        case 21 ... 30: 1
        default: 0
        }
        if let table = hsrDB.meta.equipment[id.description]?[promotion.description] {
            let summedHP = table.baseHP + table.hpAdd * (Double(level) - 1)
            let summedATK = table.baseAttack + table.attackAdd * (Double(level) - 1)
            let summedDEF = table.baseDefence + table.defenceAdd * (Double(level) - 1)
            result.append(.init(type: Enka.PropertyType.baseHP.rawValue, value: summedHP))
            result.append(.init(type: Enka.PropertyType.baseAttack.rawValue, value: summedATK))
            result.append(.init(type: Enka.PropertyType.baseDefence.rawValue, value: summedDEF))
        }
        return .init(
            props: result,
            name: hsrDB.weapons[id.description]?.equipmentName.hash ?? "-114514"
        )
    }
}
