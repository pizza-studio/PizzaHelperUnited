// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

extension HYQueriedModels.HYLAvatarDetail4HSR: HYQueriedAvatarProtocol {
    public func summarize(theDB: Enka.EnkaDB4HSR) -> Enka.AvatarSummarized? {
        let mainInfo = Enka.AvatarSummarized.AvatarMainInfo(hsrDB: theDB, hylRAW: self)
        guard let mainInfo else { return nil }
        let equipInfo = Enka.AvatarSummarized.WeaponPanel(hsrDB: theDB, hylRAW: self)
        let artifactsInfo: [Enka.AvatarSummarized.ArtifactInfo] = (relics + ornaments).compactMap { rawRelic in
            Enka.AvatarSummarized.ArtifactInfo(hsrDB: theDB, hylArtifactRAW: rawRelic)
        }
        let allPropertiesRAW = properties
        let rawProps: [Enka.PVPair] = allPropertiesRAW.compactMap { rawProp in
            Enka.PVPair(
                theDB: theDB,
                type: .init(hoyoPropID4HSR: rawProp.propertyType),
                valueStr: rawProp.propertyFinal
            )
        }

        var elementalPropMap: [Enka.GameElement: Enka.PVPair] = [:]
        rawProps.forEach {
            guard let element = $0.type.element, $0.type.rawValue.contains("AddedRatio") else { return }
            elementalPropMap[element] = $0
        }
        let prioritizedElement = mainInfo.element
        let prioritizedElementDmg: Double = elementalPropMap[mainInfo.element]?.value ?? 0
        var panel = MutableAvatarPropertyPanel(game: .genshinImpact)
        let filteredProps = rawProps.filter { propPair in
            switch propPair.type {
            case .baseHP: panel.maxHP += propPair.value
            case .baseAttack: panel.attack += propPair.value
            case .baseDefence: panel.defence += propPair.value
            case .baseSpeed: panel.speed += propPair.value
            case .criticalChanceBase: panel.criticalChance += propPair.value
            case .criticalDamageBase: panel.criticalDamage += propPair.value
            case .healRatioBase: panel.healRatio += propPair.value
            case .energyRecoveryBase: panel.energyRecovery += propPair.value
            case .statusProbabilityBase: panel.statusProbability += propPair.value
            case .statusResistanceBase: panel.statusResistance += propPair.value
            case .breakUp: panel.breakUp += propPair.value
            case _ where propPair.type.element == prioritizedElement:
                panel.elementalDMGAddedRatio = prioritizedElementDmg // 特殊处理
            default: break
            }
            return [prioritizedElement, nil].contains(propPair.type.element)
        }

        panel.triageAndHandle(theDB: theDB, filteredProps, element: prioritizedElement, isHoYoLAB: true)

        let propPair = panel.converted(theDB: theDB, element: prioritizedElement)

        return .init(
            game: .starRail,
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarPropertiesA: propPair.0,
            avatarPropertiesB: propPair.1,
            artifacts: artifactsInfo,
            isEnka: false
        ).artifactsRated()
    }
}
