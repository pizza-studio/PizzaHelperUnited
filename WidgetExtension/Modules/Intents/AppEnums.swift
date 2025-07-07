// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit
import PZWidgetsKit

// MARK: - StaminaContentRevolverStyleAppEnum

/// 注意：Xcode 不支持将 AppEnum 塞到 Swift Package 内的做法，也不支持与此有关的拆分扩展定义。

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public enum StaminaContentRevolverStyleAppEnum: String, AppEnum {
    case byDefault = "default"
    case timer
    case time
    case roundMeter = "circle"

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.StaminaContentRevolverStyle.title")

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .byDefault: "appEnum.StaminaContentRevolverStyle.byDefault",
        .timer: "appEnum.StaminaContentRevolverStyle.asTimerCountDown",
        .time: "appEnum.StaminaContentRevolverStyle.asTimeStampWhenWillAccomplish",
        .roundMeter: "appEnum.StaminaContentRevolverStyle.asRoundMeter",
    ]

    public var realValue: PZWidgetsSPM.StaminaContentRevolverStyle {
        switch self {
        case .byDefault: .byDefault
        case .timer: .timer
        case .time: .time
        case .roundMeter: .roundMeter
        }
    }
}

// MARK: - WeeklyBossesDisplayMethodAppEnum

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public enum WeeklyBossesDisplayMethodAppEnum: String, AppEnum {
    case disappearAfterCompleted
    case alwaysShow
    case neverShow

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.WeeklyBossesDisplayMethod.title")

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .disappearAfterCompleted: "appEnum.WeeklyBossesDisplayMethod.hiddenIfAllCompleted",
        .alwaysShow: "appEnum.WeeklyBossesDisplayMethod.alwaysVisible",
        .neverShow: "appEnum.WeeklyBossesDisplayMethod.alwaysHidden",
    ]

    public var realValue: PZWidgetsSPM.WeeklyBossesDisplayMethod {
        switch self {
        case .disappearAfterCompleted: .disappearAfterCompleted
        case .alwaysShow: .alwaysShow
        case .neverShow: .neverShow
        }
    }
}

// MARK: - WidgetSupportedGameAppEnum

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public enum WidgetSupportedGameAppEnum: String, AppEnum {
    case allGames = "ALL"
    case genshinImpact = "GI"
    case starRail = "HSR"
    case zenlessZone = "ZZZ"

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.WidgetSupportedGame.title")

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .allGames: "appEnum.WidgetSupportedGame.allGames",
        .genshinImpact: "appEnum.WidgetSupportedGame.GI",
        .starRail: "appEnum.WidgetSupportedGame.HSR",
        .zenlessZone: "appEnum.WidgetSupportedGame.ZZZ",
    ]

    public var realValue: Pizza.SupportedGame? {
        switch self {
        case .genshinImpact: .genshinImpact
        case .starRail: .starRail
        case .zenlessZone: .zenlessZone
        case .allGames: .none
        }
    }

    public var inverseSelectedValues: [Pizza.SupportedGame] {
        switch self {
        case .allGames: Pizza.SupportedGame.allCases
        default: Pizza.SupportedGame.allCases.filter { $0 != realValue }
        }
    }
}

// MARK: - ExpeditionDisplayPolicyAppEnum

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public enum ExpeditionDisplayPolicyAppEnum: String, AppEnum {
    case neverDisplay
    case displayWhenAvailable
    case displayExclusively

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.ExpeditionDisplayPolicy.title")

    public static let caseDisplayRepresentations: [ExpeditionDisplayPolicyAppEnum: DisplayRepresentation] = [
        .neverDisplay: "appEnum.ExpeditionDisplayPolicy.neverDisplay",
        .displayWhenAvailable: "appEnum.ExpeditionDisplayPolicy.displayWhenAvailable",
        .displayExclusively: "appEnum.ExpeditionDisplayPolicy.displayExclusively",
    ]

    public var realValue: PZWidgetsSPM.ExpeditionDisplayPolicy {
        switch self {
        case .neverDisplay: .neverDisplay
        case .displayWhenAvailable: .displayWhenAvailable
        case .displayExclusively: .displayExclusively
        }
    }
}
