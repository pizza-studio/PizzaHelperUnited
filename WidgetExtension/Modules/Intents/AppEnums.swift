// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation

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

// MARK: - WeeklyBossesShowingMethodAppEnum

public enum WeeklyBossesShowingMethodAppEnum: String, AppEnum {
    case disappearAfterCompleted
    case alwaysShow
    case neverShow

    // MARK: Public

    public static let typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "appEnum.WeeklyBossesShowingMethod.title")
    public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .disappearAfterCompleted: "appEnum.WeeklyBossesShowingMethod.hiddenIfAllCompleted",
        .alwaysShow: "appEnum.WeeklyBossesShowingMethod.alwaysVisible",
        .neverShow: "appEnum.WeeklyBossesShowingMethod.alwaysHidden",
    ]
}
