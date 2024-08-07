// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

extension Enka {
    /// 原神＆星穹铁道共用的属性类型。
    public enum PropertyType: String, Codable, Hashable, CaseIterable, RawRepresentable {
        case anemoAddedRatio = "WindAddedRatio"
        case anemoResistance = "WindResistance"
        case anemoResistanceDelta = "WindResistanceDelta"
        case physicoAddedRatio = "PhysicalAddedRatio"
        case physicoResistance = "PhysicalResistance"
        case physicoResistanceDelta = "PhysicalResistanceDelta"
        case electroAddedRatio = "ThunderAddedRatio"
        case electroResistance = "ThunderResistance"
        case electroResistanceDelta = "ThunderResistanceDelta"
        case fantasticoAddedRatio = "ImaginaryAddedRatio"
        case fantasticoResistance = "ImaginaryResistance"
        case fantasticoResistanceDelta = "ImaginaryResistanceDelta"
        case posestoAddedRatio = "QuantumAddedRatio"
        case posestoResistance = "QuantumResistance"
        case posestoResistanceDelta = "QuantumResistanceDelta"
        case pyroAddedRatio = "FireAddedRatio"
        case pyroResistance = "FireResistance"
        case pyroResistanceDelta = "FireResistanceDelta"
        case cryoAddedRatio = "IceAddedRatio"
        case cryoResistance = "IceResistance"
        case cryoResistanceDelta = "IceResistanceDelta"
        case hydroAddedRatio = "WaterAddedRatio" // GI
        case hydroResistance = "WaterResistance" // GI
        case hydroResistanceDelta = "WaterResistanceDelta" // GI
        case dendroAddedRatio = "GrassAddedRatio" // GI
        case dendroResistance = "GrassResistance" // GI
        case dendroResistanceDelta = "GrassResistanceDelta" // GI
        case geoAddedRatio = "RockAddedRatio" // GI
        case geoResistance = "RockResistance" // GI
        case geoResistanceDelta = "RockResistanceDelta" // GI
        case allDamageTypeAddedRatio = "AllDamageTypeAddedRatio"
        case attack = "Attack"
        case attackAddedRatio = "AttackAddedRatio"
        case attackDelta = "AttackDelta"
        case baseAttack = "BaseAttack"
        case baseDefence = "BaseDefence"
        case baseHP = "BaseHP"
        case baseSpeed = "BaseSpeed"
        case breakUp = "BreakUp"
        case breakDamageAddedRatio = "BreakDamageAddedRatio"
        case breakDamageAddedRatioBase = "BreakDamageAddedRatioBase"
        case criticalChance = "CriticalChance"
        case criticalChanceBase = "CriticalChanceBase"
        case criticalDamage = "CriticalDamage"
        case criticalDamageBase = "CriticalDamageBase"
        case defence = "Defence"
        case defenceAddedRatio = "DefenceAddedRatio"
        case defenceDelta = "DefenceDelta"
        case energyRecovery = "SPRatio"
        case energyRecoveryBase = "SPRatioBase"
        case healRatio = "HealRatio"
        case healRatioBase = "HealRatioBase"
        case healTakenRatio = "HealTakenRatio"
        case hpAddedRatio = "HPAddedRatio"
        case hpDelta = "HPDelta"
        case maxHP = "MaxHP"
        case energyLimit = "MaxSP"
        case speed = "Speed"
        case speedAddedRatio = "SpeedAddedRatio"
        case speedDelta = "SpeedDelta"
        case statusProbability = "StatusProbability"
        case statusProbabilityBase = "StatusProbabilityBase"
        case statusResistance = "StatusResistance"
        case statusResistanceBase = "StatusResistanceBase"
        case elementalMastery = "ElementalMastery" // GI
        case shieldCostMinusRatio = "ShieldCostMinusRatio" // GI
    }

    /// 原神词条 Enum，一律先翻译成 PropertyType 再投入使用。
    fileprivate enum GIAvatarAttribute: String, Codable, Hashable, CaseIterable, RawRepresentable {
        case baseAttack = "FIGHT_PROP_BASE_ATTACK"
        case maxHP = "FIGHT_PROP_MAX_HP"
        case attack = "FIGHT_PROP_ATTACK"
        case defence = "FIGHT_PROP_DEFENSE"
        case elementalMastery = "FIGHT_PROP_ELEMENT_MASTERY"
        case critRate = "FIGHT_PROP_CRITICAL"
        case critDmg = "FIGHT_PROP_CRITICAL_HURT"
        case healAmp = "FIGHT_PROP_HEAL_ADD"
        case healedAmp = "FIGHT_PROP_HEALED_ADD"
        case chargeEfficiency = "FIGHT_PROP_CHARGE_EFFICIENCY"
        case shieldCostMinusRatio = "FIGHT_PROP_SHIELD_COST_MINUS_RATIO"
        case dmgAmpPyro = "FIGHT_PROP_FIRE_ADD_HURT"
        case dmgAmpHydro = "FIGHT_PROP_WATER_ADD_HURT"
        case dmgAmpDendro = "FIGHT_PROP_GRASS_ADD_HURT"
        case dmgAmpElectro = "FIGHT_PROP_ELEC_ADD_HURT"
        case dmgAmpAnemo = "FIGHT_PROP_WIND_ADD_HURT"
        case dmgAmpCryo = "FIGHT_PROP_ICE_ADD_HURT"
        case dmgAmpGeo = "FIGHT_PROP_ROCK_ADD_HURT"
        case dmgAmpPhysico = "FIGHT_PROP_PHYSICAL_ADD_HURT"
        case hp = "FIGHT_PROP_HP"
        case attackAmp = "FIGHT_PROP_ATTACK_PERCENT"
        case hpAmp = "FIGHT_PROP_HP_PERCENT"
        case defenceAmp = "FIGHT_PROP_DEFENSE_PERCENT"
    }
}

extension Enka.PropertyType {
    public init?(rawValue: String) {
        let rawMatched = Self.allCases.first { $0.rawValue == rawValue }
        guard let matched = rawMatched
            ?? Enka.GIAvatarAttribute(rawValue: rawValue)?.asPropertyType
        else { return nil }
        self = matched
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let debugDescription = "Wrong type decodable for Enka.PropertyType"
        let error = DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: debugDescription
            )
        )
        guard let rawStr = try? container.decode(String.self) else {
            throw error
        }
        let rawMatched = Self.allCases.first(where: { $0.rawValue == rawStr })
        guard let matched = rawMatched ?? Self(rawValue: rawStr) else {
            throw error
        }
        self = matched
    }
}

extension Enka.GIAvatarAttribute {
    var asPropertyType: Enka.PropertyType {
        switch self {
        case .baseAttack: return .baseAttack
        case .maxHP: return .maxHP
        case .attack: return .attack
        case .defence: return .defence
        case .elementalMastery: return .elementalMastery
        case .critRate: return .criticalChance
        case .critDmg: return .criticalDamage
        case .healAmp: return .healRatio
        case .healedAmp: return .healTakenRatio
        case .chargeEfficiency: return .energyRecovery
        case .shieldCostMinusRatio: return .shieldCostMinusRatio
        case .dmgAmpPyro: return .pyroAddedRatio
        case .dmgAmpHydro: return .hydroAddedRatio
        case .dmgAmpDendro: return .dendroAddedRatio
        case .dmgAmpElectro: return .electroAddedRatio
        case .dmgAmpAnemo: return .anemoAddedRatio
        case .dmgAmpCryo: return .cryoAddedRatio
        case .dmgAmpGeo: return .geoAddedRatio
        case .dmgAmpPhysico: return .physicoAddedRatio
        case .hp: return .maxHP
        case .attackAmp: return .attackAddedRatio
        case .hpAmp: return .hpAddedRatio
        case .defenceAmp: return .defenceAddedRatio
        }
    }
}
