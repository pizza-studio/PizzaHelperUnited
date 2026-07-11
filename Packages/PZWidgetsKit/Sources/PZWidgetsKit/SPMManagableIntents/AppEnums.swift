// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit

// MARK: - StaminaContentRevolverStyleAppEnum

/// 注意：Xcode 不支持将 AppEnum 塞到 Swift Package 内的做法，也不支持与此有关的拆分扩展定义。

@available(iOS 17.0, macCatalyst 17.0, *)
public enum StaminaContentRevolverStyleAppEnum: String, AppEnum {
    case byDefault = "default"
    case timer
    case time
    case roundMeter = "circle"

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: LocalizedStringResource(
            "appEnum.StaminaContentRevolverStyle.title",
            bundle: .currentSPM
        ))

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .byDefault: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.StaminaContentRevolverStyle.byDefault",
                bundle: .currentSPM
            )
        ),
        .timer: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.StaminaContentRevolverStyle.asTimerCountDown",
                bundle: .currentSPM
            )
        ),
        .time: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.StaminaContentRevolverStyle.asTimeStampWhenWillAccomplish",
                bundle: .currentSPM
            )
        ),
        .roundMeter: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.StaminaContentRevolverStyle.asRoundMeter",
                bundle: .currentSPM
            )
        ),
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

@available(iOS 17.0, macCatalyst 17.0, *)
public enum WeeklyBossesDisplayMethodAppEnum: String, AppEnum {
    case disappearAfterCompleted
    case alwaysShow
    case neverShow

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: LocalizedStringResource(
            "appEnum.WeeklyBossesDisplayMethod.title",
            bundle: .currentSPM
        ))

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .disappearAfterCompleted: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WeeklyBossesDisplayMethod.hiddenIfAllCompleted",
                bundle: .currentSPM
            )
        ),
        .alwaysShow: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WeeklyBossesDisplayMethod.alwaysVisible",
                bundle: .currentSPM
            )
        ),
        .neverShow: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WeeklyBossesDisplayMethod.alwaysHidden",
                bundle: .currentSPM
            )
        ),
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

@available(iOS 17.0, macCatalyst 17.0, *)
public enum WidgetSupportedGameAppEnum: String, AppEnum {
    case allGames = "ALL"
    case genshinImpact = "GI"
    case starRail = "HSR"
    case zenlessZone = "ZZZ"

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: LocalizedStringResource(
            "appEnum.WidgetSupportedGame.title",
            bundle: .currentSPM
        ))

    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .allGames: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WidgetSupportedGame.allGames",
                bundle: .currentSPM
            )
        ),
        .genshinImpact: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WidgetSupportedGame.GI",
                bundle: .currentSPM
            )
        ),
        .starRail: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WidgetSupportedGame.HSR",
                bundle: .currentSPM
            )
        ),
        .zenlessZone: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.WidgetSupportedGame.ZZZ",
                bundle: .currentSPM
            )
        ),
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

@available(iOS 17.0, macCatalyst 17.0, *)
public enum ExpeditionDisplayPolicyAppEnum: String, AppEnum {
    case neverDisplay
    case displayWhenAvailable
    case displayExclusively

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: LocalizedStringResource(
            "appEnum.ExpeditionDisplayPolicy.title",
            bundle: .currentSPM
        ))

    public static let caseDisplayRepresentations: [ExpeditionDisplayPolicyAppEnum: DisplayRepresentation] = [
        .neverDisplay: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.ExpeditionDisplayPolicy.neverDisplay",
                bundle: .currentSPM
            )
        ),
        .displayWhenAvailable: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.ExpeditionDisplayPolicy.displayWhenAvailable",
                bundle: .currentSPM
            )
        ),
        .displayExclusively: DisplayRepresentation(
            title: LocalizedStringResource(
                "appEnum.ExpeditionDisplayPolicy.displayExclusively",
                bundle: .currentSPM
            )
        ),
    ]

    public var realValue: PZWidgetsSPM.ExpeditionDisplayPolicy {
        switch self {
        case .neverDisplay: .neverDisplay
        case .displayWhenAvailable: .displayWhenAvailable
        case .displayExclusively: .displayExclusively
        }
    }
}
