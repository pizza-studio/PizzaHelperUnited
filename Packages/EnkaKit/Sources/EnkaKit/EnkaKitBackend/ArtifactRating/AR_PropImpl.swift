// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// swiftlint:disable cyclomatic_complexity
extension Enka.PropertyType {
    public var appraisableArtifactParam: ArtifactRating.Appraiser.Param? {
        switch self {
        case .hpDelta: return .hpDelta
        case .attack, .attackDelta: return .atkDelta
        case .defence, .defenceDelta: return .defDelta
        case .hpAddedRatio, .maxHP: return .hpAmp
        case .attackAddedRatio: return .atkAmp
        case .defenceAddedRatio, .shieldCostMinusRatio: return .defAmp
        case .speedDelta: return .spdDelta
        case .criticalChance, .criticalChanceBase: return .critChance
        case .criticalDamage, .criticalDamageBase: return .critDamage
        case .statusProbabilityBase: return .statProb
        case .statusResistanceBase: return .statResis
        case .breakDamageAddedRatioBase: return .breakDmg
        case .healRatio, .healRatioBase: return .healAmp
        case .energyRecoveryBase: return .energyRecovery
        case .physicoAddedRatio: return .dmgAmp(.physico)
        case .pyroAddedRatio: return .dmgAmp(.pyro)
        case .cryoAddedRatio: return .dmgAmp(.cryo)
        case .electroAddedRatio: return .dmgAmp(.electro)
        case .anemoAddedRatio: return .dmgAmp(.anemo)
        case .posestoAddedRatio: return .dmgAmp(.posesto)
        case .fantasticoAddedRatio: return .dmgAmp(.fantastico)
        case .geoAddedRatio: return .dmgAmp(.geo)
        case .hydroAddedRatio: return .dmgAmp(.hydro)
        case .dendroAddedRatio: return .dmgAmp(.dendro)
        case .elementalMastery: return .elementalMastery
        case .energyRecovery: return .energyRecovery
        default: return nil
        }
    }
}

// swiftlint:enable cyclomatic_complexity
