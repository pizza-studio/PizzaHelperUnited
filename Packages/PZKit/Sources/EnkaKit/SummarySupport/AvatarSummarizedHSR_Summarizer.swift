// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

extension Enka.QueriedProfileHSR.RawAvatar {
    public func summarize(theDB: Enka.EnkaDB4HSR) -> Enka.AvatarSummarizedHSR? {
        // Main Info
        let baseSkillSet = Enka.AvatarSummarizedHSR.AvatarMainInfo.BaseSkillSet(
            theDB: theDB,
            constellation: rank ?? 0,
            fetched: skillTreeList
        )
        guard let baseSkillSet = baseSkillSet else { return nil }

        let mainInfo = Enka.AvatarSummarizedHSR.AvatarMainInfo(
            theDB: theDB,
            charID: avatarId,
            avatarLevel: level,
            constellation: rank ?? 0,
            baseSkills: baseSkillSet
        )
        guard let mainInfo = mainInfo else { return nil }

        let equipInfo: Enka.AvatarSummarizedHSR.WeaponPanel? = {
            guard let equipment = equipment else { return nil }
            return Enka.AvatarSummarizedHSR.WeaponPanel(theDB: theDB, fetched: equipment)
        }()

        let artifactsInfo = artifactList.compactMap {
            Enka.AvatarSummarizedHSR.ArtifactInfo(theDB: theDB, fetched: $0)
        }

        // Panel: Add basic values from catched character Metadata.
        let baseMetaCharacter = theDB.meta.avatar[avatarId.description]?[promotion.description]
        guard let baseMetaCharacter = baseMetaCharacter else { return nil }
        var panel = MutableAvatarPropertyPanel()
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

        if let equipFlat: Enka.QueriedProfileHSR.EquipmentFlat = equipment?.getFlat(theDB: theDB) {
            panel.maxHP += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseHP }?.value ?? 0
            panel.attack += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseAttack }?.value ?? 0
            panel.defence += equipFlat.props.first { Enka.PropertyType(rawValue: $0.type) == .baseDefence }?
                .value ?? 0
        }

        // Panel: Handle all additional props

        // Panel: - Additional Props from the Weapon.

        let weaponSpecialProps: [Enka.AvatarSummarizedHSR.PropertyPair] = equipInfo?.specialProps ?? []

        // Panel: Base and Additional Props from the Skill Tree.

        let skillTreeProps: [Enka.AvatarSummarizedHSR.PropertyPair] = skillTreeList.compactMap { currentNode in
            if currentNode.level == 1 {
                return theDB.meta.tree.query(id: currentNode.pointId, stage: 1).map {
                    Enka.AvatarSummarizedHSR.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
            }
            return nil
        }.reduce([], +)

        // Panel: - Additional Props from the Artifacts.

        let artifactProps: [Enka.AvatarSummarizedHSR.PropertyPair] = artifactsInfo.map(\.allProps).reduce([], +)

        // Panel: - Additional Props from the Artifact Set Effects.

        let artifactSetProps: [Enka.AvatarSummarizedHSR.PropertyPair] = {
            var resultPairs = [Enka.AvatarSummarizedHSR.PropertyPair]()
            var setIDCounters: [Int: Int] = [:]
            artifactsInfo.map(\.setID).forEach { setIDCounters[$0, default: 0] += 1 }
            setIDCounters.forEach { setId, count in
                guard count >= 2 else { return }
                let x = theDB.meta.relic.setSkill.query(id: setId, stage: 2).map {
                    Enka.AvatarSummarizedHSR.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: x)
                guard count >= 4 else { return }
                let y = theDB.meta.relic.setSkill.query(id: setId, stage: 4).map {
                    Enka.AvatarSummarizedHSR.PropertyPair(theDB: theDB, type: $0.key, value: $0.value)
                }
                resultPairs.append(contentsOf: y)
            }
            return resultPairs
        }()

        // Panel: Triage and Handle.

        let allProps = skillTreeProps + weaponSpecialProps + artifactProps + artifactSetProps
        panel.triageAndHandle(theDB: theDB, allProps, element: mainInfo.element)

        // Panel: Final Output.

        let propPair = panel.converted(theDB: theDB, element: mainInfo.element)

        return Enka.AvatarSummarizedHSR(
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarPropertiesA: propPair.0,
            avatarPropertiesB: propPair.1,
            artifacts: artifactsInfo
        ) // .artifactsRated()
    }
}

// MARK: - MutableAvatarPropertyPanel

private struct MutableAvatarPropertyPanel {
    // MARK: Public

    public var maxHP: Double = 0
    public var attack: Double = 0
    public var defence: Double = 0
    public var speed: Double = 0
    public var criticalChance: Double = 0
    public var criticalDamage: Double = 0
    public var breakUp: Double = 0
    public var energyRecovery: Double = 1
    public var statusProbability: Double = 0
    public var statusResistance: Double = 0
    public var healRatio: Double = 0
    public var elementalDMGAddedRatio: Double = 0

    public func converted(
        theDB: Enka.EnkaDB4HSR,
        element: Enka.GameElement
    )
        -> ([Enka.AvatarSummarizedHSR.PropertyPair], [Enka.AvatarSummarizedHSR.PropertyPair]) {
        var resultA = [Enka.AvatarSummarizedHSR.PropertyPair]()
        var resultB = [Enka.AvatarSummarizedHSR.PropertyPair]()
        resultA.append(.init(theDB: theDB, type: .maxHP, value: maxHP))
        resultA.append(.init(theDB: theDB, type: .attack, value: attack))
        resultA.append(.init(theDB: theDB, type: .defence, value: defence))
        resultA.append(.init(theDB: theDB, type: .speed, value: speed))
        resultA.append(.init(theDB: theDB, type: .criticalChance, value: criticalChance))
        resultA.append(.init(theDB: theDB, type: .criticalDamage, value: criticalDamage))
        resultB.append(.init(theDB: theDB, type: element.damageAddedRatioProperty, value: elementalDMGAddedRatio))
        resultB.append(.init(theDB: theDB, type: .breakDamageAddedRatio, value: breakUp))
        resultB.append(.init(theDB: theDB, type: .healRatio, value: healRatio))
        resultB.append(.init(theDB: theDB, type: .energyRecovery, value: energyRecovery))
        resultB.append(.init(theDB: theDB, type: .statusProbability, value: statusProbability))
        resultB.append(.init(theDB: theDB, type: .statusResistance, value: statusResistance))
        return (resultA, resultB)
    }

    /// Triage the property pairs into two categories, and then handle them.
    /// - Parameters:
    ///   - newProps: An array of property pairs to addup to self.
    ///   - element: The element of the character, affecting which element's damange added ratio will be respected.
    public mutating func triageAndHandle(
        theDB: Enka.EnkaDB4HSR,
        _ newProps: [Enka.AvatarSummarizedHSR.PropertyPair],
        element: Enka.GameElement
    ) {
        var propAmplifiers = [Enka.AvatarSummarizedHSR.PropertyPair]()
        var propAdditions = [Enka.AvatarSummarizedHSR.PropertyPair]()
        newProps.forEach { $0.triage(amp: &propAmplifiers, add: &propAdditions, element: element) }

        var propAmpDictionary: [Enka.PropertyType: Double] = [:]
        propAmplifiers.forEach {
            propAmpDictionary[$0.type, default: 0] += $0.value
        }

        propAmpDictionary.forEach { key, value in
            handle(.init(theDB: theDB, type: key, value: value), element: element)
        }

        propAdditions.forEach { handle($0, element: element) }
    }

    // MARK: Private

    // swiftlint:disable cyclomatic_complexity
    private mutating func handle(
        _ prop: Enka.AvatarSummarizedHSR.PropertyPair,
        element: Enka.GameElement
    ) {
        switch prop.type {
        // 星穹铁道没有附魔，所以只要是与角色属性不匹配的元素伤害加成都是狗屁。
        case .allDamageTypeAddedRatio, element.damageAddedRatioProperty:
            elementalDMGAddedRatio += prop.value
        case .attack, .attackDelta, .baseAttack: attack += prop.value
        case .attackAddedRatio: attack *= (1 + prop.value)
        case .baseHP, .hpDelta, .maxHP: maxHP += prop.value
        case .hpAddedRatio: maxHP *= (1 + prop.value)
        case .baseSpeed, .speed, .speedDelta: speed += prop.value
        case .speedAddedRatio: speed *= (1 + prop.value)
        case .criticalChance, .criticalChanceBase: criticalChance += prop.value
        case .criticalDamage, .criticalDamageBase: criticalDamage += prop.value
        case .baseDefence, .defence, .defenceDelta: defence += prop.value
        case .defenceAddedRatio: defence *= (1 + prop.value)
        case .energyRecovery, .energyRecoveryBase: energyRecovery += prop.value
        case .healRatio, .healRatioBase: healRatio += prop.value
        case .statusProbability, .statusProbabilityBase: statusProbability += prop.value
        case .statusResistance, .statusResistanceBase: statusResistance += prop.value
        case .breakDamageAddedRatio, .breakDamageAddedRatioBase, .breakUp:
            breakUp += prop.value
        default: return
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension Enka.AvatarSummarizedHSR.PropertyPair {
    func triage(
        amp arrAmp: inout [Enka.AvatarSummarizedHSR.PropertyPair],
        add arrAdd: inout [Enka.AvatarSummarizedHSR.PropertyPair],
        element: Enka.GameElement
    ) {
        switch type {
        case .attackAddedRatio, .defenceAddedRatio, .hpAddedRatio, .speedAddedRatio: arrAmp.append(self)
        case .allDamageTypeAddedRatio, .attack, .attackDelta,
             .baseAttack, .baseDefence, .baseHP, .baseSpeed,
             .breakDamageAddedRatio, .breakDamageAddedRatioBase,
             .breakUp, .criticalChance, .criticalChanceBase,
             .criticalDamage, .criticalDamageBase, .defence,
             .defenceDelta, element.damageAddedRatioProperty,
             .energyRecovery, .energyRecoveryBase,
             .healRatio, .healRatioBase,
             .hpDelta, .maxHP, .speed,
             .speedDelta, .statusProbability,
             .statusProbabilityBase, .statusResistance,
             .statusResistanceBase:
            arrAdd.append(self)
        default: break
        }
    }
}

extension Enka.QueriedProfileHSR.ArtifactItem {
    public func getFlat(theDB: Enka.EnkaDB4HSR) -> Enka.QueriedProfileHSR.ArtifactItem.SteppedFlat? {
        var result = [Enka.QueriedProfileHSR.PropStepped]()
        guard let matchedArtifact = theDB.artifacts[tid.description] else { return nil }
        let mainAffix = theDB.meta.relic.mainAffix[
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
            guard let subAffix = theDB.meta.relic.subAffix[
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

extension Enka.QueriedProfileHSR.Equipment {
    public func getFlat(theDB: Enka.EnkaDB4HSR) -> Enka.QueriedProfileHSR.EquipmentFlat {
        var result = [Enka.QueriedProfileHSR.Prop]()
        if let table = theDB.meta.equipment[tid.description]?[(promotion ?? 0).description] {
            let summedHP = table.baseHP + table.hpAdd * (Double(level) - 1)
            let summedATK = table.baseAttack + table.attackAdd * (Double(level) - 1)
            let summedDEF = table.baseDefence + table.defenceAdd * (Double(level) - 1)
            result.append(.init(type: Enka.PropertyType.baseHP.rawValue, value: summedHP))
            result.append(.init(type: Enka.PropertyType.baseAttack.rawValue, value: summedATK))
            result.append(.init(type: Enka.PropertyType.baseDefence.rawValue, value: summedDEF))
        }
        return .init(props: result, name: theDB.weapons[tid.description]?.equipmentName.hash ?? 0)
    }
}
