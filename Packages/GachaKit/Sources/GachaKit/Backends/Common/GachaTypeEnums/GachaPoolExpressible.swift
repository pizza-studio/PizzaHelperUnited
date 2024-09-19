// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - GachaPoolExpressible

/// 该 Enum 仅用于前台显示之用途，不参与后台资料处理、不承载任何附加参数资讯。
public enum GachaPoolExpressible: String, Identifiable, Equatable, Hashable, Sendable, CaseIterable {
    case giUnknown
    case giBeginnersWish
    case giStandardWish
    case giCharacterEventWish // 两个限定池合并显示
    case giWeaponEventWish
    case giChronicledWish
    case srUnknown
    case srStellarWarp
    case srCharacterEventWarp
    case srLightConeEventWarp
    case srDepartureWarp
    case zzUnknown
    case zzStableChannel
    case zzExclusiveChannel
    case zzWEngineChannel
    case zzBangbooChannel // 非限定池
}

extension GachaPoolExpressible {
    public init(_ gachaTypeStr: String, game: Pizza.SupportedGame) {
        switch game {
        case .genshinImpact: self = GachaTypeGI(rawValue: gachaTypeStr).expressible
        case .starRail: self = GachaTypeHSR(rawValue: gachaTypeStr).expressible
        case .zenlessZone: self = GachaTypeZZZ(rawValue: gachaTypeStr).expressible
        }
    }

    // MARK: Public

    public static func getKnownCases(by game: Pizza.SupportedGame) -> [Self] {
        Self.allCases.filter { $0.game == game && !$0.isUnknown }
    }

    public static func getPoolFilterLabel(by game: Pizza.SupportedGame) -> String {
        "gachaKit.poolFilterLabel.byGame.\(game.rawValue)".i18nGachaKit
    }

    public var id: String { rawValue }

    public var isUnknown: Bool {
        [.giUnknown, .srUnknown, .zzUnknown].contains(self)
    }

    public var localizedTitle: String {
        "gachaKit.poolType.\(rawValue)".i18nGachaKit
    }

    public var game: Pizza.SupportedGame {
        switch self {
        case .giUnknown: .genshinImpact
        case .giBeginnersWish: .genshinImpact
        case .giStandardWish: .genshinImpact
        case .giCharacterEventWish: .genshinImpact
        case .giWeaponEventWish: .genshinImpact
        case .giChronicledWish: .genshinImpact
        case .srUnknown: .starRail
        case .srStellarWarp: .starRail
        case .srCharacterEventWarp: .starRail
        case .srLightConeEventWarp: .starRail
        case .srDepartureWarp: .starRail
        case .zzUnknown: .zenlessZone
        case .zzStableChannel: .zenlessZone
        case .zzExclusiveChannel: .zenlessZone
        case .zzWEngineChannel: .zenlessZone
        case .zzBangbooChannel: .zenlessZone
        }
    }

    public var isSurinukable: Bool {
        switch self {
        case .giUnknown: false
        case .giBeginnersWish: false
        case .giStandardWish: false
        case .giCharacterEventWish: true
        case .giWeaponEventWish: true
        case .giChronicledWish: false
        case .srUnknown: false
        case .srStellarWarp: false
        case .srCharacterEventWarp: true
        case .srLightConeEventWarp: true
        case .srDepartureWarp: false
        case .zzUnknown: false
        case .zzStableChannel: false
        case .zzExclusiveChannel: true
        case .zzWEngineChannel: true
        case .zzBangbooChannel: false
        }
    }

    /// 该动态 property 用来辅助 Predicate 筛选。所有目前未知的卡池在这里都指定「-114514」。
    public var rawValueForKnownPools: String {
        switch self {
        case .giUnknown: "-114514"
        case .giBeginnersWish: GachaTypeGI.beginnersWish.rawValue
        case .giStandardWish: GachaTypeGI.standardWish.rawValue
        case .giCharacterEventWish: GachaTypeGI.UIGFGachaType.standardWish.rawValue
        case .giWeaponEventWish: GachaTypeGI.weaponEventWish.rawValue
        case .giChronicledWish: GachaTypeGI.chronicledWish.rawValue
        case .srUnknown: "-114514"
        case .srStellarWarp: GachaTypeHSR.stellarWarp.rawValue
        case .srCharacterEventWarp: GachaTypeHSR.characterEventWarp.rawValue
        case .srLightConeEventWarp: GachaTypeHSR.lightConeEventWarp.rawValue
        case .srDepartureWarp: GachaTypeHSR.departureWarp.rawValue
        case .zzUnknown: "-114514"
        case .zzStableChannel: GachaTypeZZZ.stableChannel.rawValue
        case .zzExclusiveChannel: GachaTypeZZZ.exclusiveChannel.rawValue
        case .zzWEngineChannel: GachaTypeZZZ.wEngineChannel.rawValue
        case .zzBangbooChannel: GachaTypeZZZ.bangbooChannel.rawValue
        }
    }

    public var appraiserDescriptionKey: String {
        switch game {
        case .genshinImpact: "gachaKit.reviewFromAppraiser.gi"
        case .starRail: "gachaKit.reviewFromAppraiser.hsr"
        case .zenlessZone: "gachaKit.reviewFromAppraiser.zzz"
        }
    }
}
