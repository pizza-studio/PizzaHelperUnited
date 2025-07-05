// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - MutableAvatarPropertyPanel

/// 一个即用即抛的类型，用来快速整理角色面板。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct MutableAvatarPropertyPanel {
    // MARK: Lifecycle

    public init(game: Enka.GameType) {
        switch game {
        case .genshinImpact: self.energyRecovery = 0
        case .starRail: self.energyRecovery = 1
        case .zenlessZone: self.energyRecovery = 0 // 临时设定。
        }
    }

    // MARK: Public

    public var maxHP: Double = 0
    public var attack: Double = 0
    public var defence: Double = 0
    public var speed: Double = 0
    public var criticalChance: Double = 0
    public var criticalDamage: Double = 0
    public var elementalMastery: Double = 0
    public var energyRecovery: Double // 用建构子来赋值。
    public var statusProbability: Double = 0
    public var statusResistance: Double = 0
    public var healRatio: Double = 0
    public var elementalDMGAddedRatio: Double = 0
    public var breakUp: Double = 0
    public var shieldEffectivity: Double = 0

    public func converted(
        theDB: some EnkaDBProtocol,
        element: Enka.GameElement
    )
        -> ([Enka.PVPair], [Enka.PVPair]) {
        var resultA = [Enka.PVPair]()
        var resultB = [Enka.PVPair]()
        resultA.append(.init(theDB: theDB, type: .maxHP, value: maxHP))
        resultA.append(.init(theDB: theDB, type: .attack, value: attack))
        resultA.append(.init(theDB: theDB, type: .defence, value: defence))
        if theDB.game == .starRail {
            resultA.append(.init(theDB: theDB, type: .speed, value: speed))
        }
        resultA.append(.init(theDB: theDB, type: .criticalChance, value: criticalChance))
        resultA.append(.init(theDB: theDB, type: .criticalDamage, value: criticalDamage))
        resultB.append(.init(theDB: theDB, type: element.damageAddedRatioProperty, value: elementalDMGAddedRatio))
        switch theDB.game {
        case .genshinImpact:
            resultB.append(.init(theDB: theDB, type: .elementalMastery, value: elementalMastery))
        case .starRail:
            resultB.append(.init(theDB: theDB, type: .breakDamageAddedRatio, value: breakUp))
        case .zenlessZone: break // 临时设定。
        }
        resultB.append(.init(theDB: theDB, type: .healRatio, value: healRatio))
        resultB.append(.init(theDB: theDB, type: .energyRecovery, value: energyRecovery))
        switch theDB.game {
        case .genshinImpact:
            resultB.append(.init(theDB: theDB, type: .shieldCostMinusRatio, value: shieldEffectivity))
        case .starRail:
            resultB.append(.init(theDB: theDB, type: .statusProbability, value: statusProbability))
            resultB.append(.init(theDB: theDB, type: .statusResistance, value: statusResistance))
        case .zenlessZone: break // 临时设定。
        }
        return (resultA, resultB)
    }

    /// Triage the property pairs into two categories, and then handle them.
    /// - Parameters:
    ///   - newProps: An array of property pairs to addup to self.
    ///   - element: The element of the character, affecting which element's damange added ratio will be respected.
    public mutating func triageAndHandle(
        theDB: some EnkaDBProtocol,
        _ newProps: [Enka.PVPair],
        element: Enka.GameElement,
        isHoYoLAB: Bool = false
    ) {
        switch theDB.game {
        case .zenlessZone: return // 临时设定。
        case .genshinImpact: return // 原神直接使用 Enka 预先计算的面板结果。
        case .starRail:
            guard !isHoYoLAB else { return } // HoYoLAB 的面板是提前计算好了的。
            var propAmplifiers = [Enka.PVPair]()
            var propAdditions = [Enka.PVPair]()
            newProps.forEach { $0.triage(amp: &propAmplifiers, add: &propAdditions, element: element) }

            var propAmpDictionary: [Enka.PropertyType: Double] = [:]
            propAmplifiers.forEach {
                propAmpDictionary[$0.type, default: 0] += $0.value
            }

            propAmpDictionary.forEach { key, value in
                handleValueSummary(.init(theDB: theDB, type: key, value: value), element: element)
            }

            propAdditions.forEach { handleValueSummary($0, element: element) }
        }
    }

    // MARK: Private

    // swiftlint:disable cyclomatic_complexity
    /// 星穹铁道专用面板计算函式。
    private mutating func handleValueSummary(
        _ prop: Enka.PVPair,
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
        case .elementalMastery: elementalMastery += prop.value
        case .shieldCostMinusRatio: shieldEffectivity += prop.value
        default: return
        }
    }
}
