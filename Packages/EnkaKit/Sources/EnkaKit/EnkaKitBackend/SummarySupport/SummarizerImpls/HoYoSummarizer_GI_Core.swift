// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

extension HYQueriedModels.HYLAvatarDetail4GI: HYQueriedAvatarProtocol {
    public static func cacheLocalHoYoAvatars(uid: String, data: Data) {
        let decoded = try? Self.DecodableList.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HYQueriedModels.HYLAvatarDetail4GI.getLocalHoYoProfiles()"
        )
        guard let decoded else { return }
        Defaults[.queriedHoYoProfiles4GI]["GI-\(uid)"] = decoded.avatarList
    }

    public static func getLocalHoYoAvatars(theDB: DBType, uid: String) -> [Enka.AvatarSummarized] {
        let cachedData = Defaults[.queriedHoYoProfiles4GI]["GI-\(uid)"] ?? []
        return cachedData.compactMap { $0.summarize(theDB: theDB) }
    }

    public func summarize(theDB: Enka.EnkaDB4GI) -> Enka.AvatarSummarized? {
        let mainInfo = Enka.AvatarSummarized.AvatarMainInfo(giDB: theDB, hylRAW: self)
        guard let mainInfo else { return nil }
        let equipInfo = Enka.AvatarSummarized.WeaponPanel(giDB: theDB, hylRAW: self)
        guard let equipInfo else { return nil }
        let artifactsInfo: [Enka.AvatarSummarized.ArtifactInfo] = relics.compactMap { rawRelic in
            Enka.AvatarSummarized.ArtifactInfo(giDB: theDB, hylArtifactRAW: rawRelic)
        }
        let allPropertiesRAW = baseProperties + extraProperties + elementProperties
        let rawProps: [Enka.PVPair] = allPropertiesRAW.compactMap { rawProp in
            Enka.PVPair(
                theDB: theDB,
                type: .init(hoyoPropID4GI: rawProp.propertyType),
                valueStr: rawProp.propertyFinal
            )
        }

        // 从角色面板当中找出最强的元素伤害增幅词条。
        // 由于角色在不带杯子的情况下可能会有自身的元素伤害加成，所以需要分开处理。
        // 比如说你要让胡桃在坎蒂丝开大之后打水伤输出的话（乐子玩法）就可能会需要优先显示水伤加成。
        // 又比如说优菈、辛焱、雷泽等物理大剑，明明各自有各自的提瓦特元素属性，但往往都只会堆物理伤害加成。
        var elementalPropMap: [Enka.GameElement: Enka.PVPair] = [:]
        rawProps.forEach {
            guard let element = $0.type.element, $0.type.rawValue.contains("AddedRatio") else { return }
            elementalPropMap[element] = $0
        }
        var prioritizedElement = mainInfo.element
        var prioritizedElementDmg: Double = elementalPropMap[mainInfo.element]?.value ?? 0
        updateElement: for pair in elementalPropMap.values {
            if pair.value > prioritizedElementDmg, let newElement = pair.type.element {
                prioritizedElement = newElement
                prioritizedElementDmg = pair.value
                break updateElement
            }
        }
        var panel = MutableAvatarPropertyPanel(game: .genshinImpact)
        let filteredProps = rawProps.filter { propPair in
            switch propPair.type {
            case .attack: panel.attack += propPair.value
            case .defence: panel.defence += propPair.value
            case .maxHP: panel.maxHP += propPair.value
            case .criticalChance: panel.criticalChance += propPair.value
            case .criticalDamage: panel.criticalDamage += propPair.value
            case .elementalMastery: panel.elementalMastery += propPair.value
            case .healRatio: panel.healRatio += propPair.value
            case .energyRecovery: panel.energyRecovery += propPair.value
            case .shieldCostMinusRatio: panel.energyRecovery += propPair.value
            case _ where propPair.type.element == prioritizedElement:
                panel.elementalDMGAddedRatio = prioritizedElementDmg // 特殊处理
            default: break
            }
            return [prioritizedElement, nil].contains(propPair.type.element)
        }

        panel.triageAndHandle(theDB: theDB, filteredProps, element: prioritizedElement)

        let propPair = panel.converted(theDB: theDB, element: prioritizedElement)

        return .init(
            game: .genshinImpact,
            mainInfo: mainInfo,
            equippedWeapon: equipInfo,
            avatarPropertiesA: propPair.0,
            avatarPropertiesB: propPair.1,
            artifacts: artifactsInfo,
            isEnka: false
        ).artifactsRated()
    }
}
