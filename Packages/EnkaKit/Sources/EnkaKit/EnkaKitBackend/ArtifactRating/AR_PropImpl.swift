// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// swiftlint:disable cyclomatic_complexity
extension Enka.PropertyType {
    public var appraisableArtifactParam: ArtifactRating.Appraiser.Param? {
        switch self {
        case .hpDelta: .hpDelta
        case .attack, .attackDelta: .atkDelta
        case .defence, .defenceDelta: .defDelta
        case .hpAddedRatio, .maxHP: .hpAmp
        case .attackAddedRatio: .atkAmp
        case .defenceAddedRatio, .shieldCostMinusRatio: .defAmp
        case .speedDelta: .spdDelta
        case .criticalChance, .criticalChanceBase: .critChance
        case .criticalDamage, .criticalDamageBase: .critDamage
        case .statusProbabilityBase: .statProb
        case .statusResistanceBase: .statResis
        case .breakDamageAddedRatioBase: .breakDmg
        case .healRatio, .healRatioBase: .healAmp
        case .energyRecoveryBase: .energyRecovery
        case .physicoAddedRatio: .dmgAmp(.physico)
        case .pyroAddedRatio: .dmgAmp(.pyro)
        case .cryoAddedRatio: .dmgAmp(.cryo)
        case .electroAddedRatio: .dmgAmp(.electro)
        case .anemoAddedRatio: .dmgAmp(.anemo)
        case .posestoAddedRatio: .dmgAmp(.posesto)
        case .fantasticoAddedRatio: .dmgAmp(.fantastico)
        case .geoAddedRatio: .dmgAmp(.geo)
        case .hydroAddedRatio: .dmgAmp(.hydro)
        case .dendroAddedRatio: .dmgAmp(.dendro)
        case .elementalMastery: .elementalMastery
        case .energyRecovery: .energyRecovery
        default: nil
        }
    }
}

// swiftlint:enable cyclomatic_complexity
