// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit

// MARK: - AutoRotationUsingResinWidgetStyleAppEnum

public enum AutoRotationUsingResinWidgetStyleAppEnum: String, AppEnum {
    case byDefault = "default"
    case timer
    case time
    case roundMeter = "circle"

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.AutoRotationUsingResinWidgetStyle.title")
    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .byDefault: "appEnum.AutoRotationUsingResinWidgetStyle.byDefault",
        .timer: "appEnum.AutoRotationUsingResinWidgetStyle.asTimerCountDown",
        .time: "appEnum.AutoRotationUsingResinWidgetStyle.asTimeStampWhenWillAccomplish",
        .roundMeter: "appEnum.AutoRotationUsingResinWidgetStyle.asRoundMeter",
    ]
}

// MARK: - WeeklyBossesDisplayMethodAppEnum

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
}

// MARK: - WidgetSupportedGameAppEnum

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
}
