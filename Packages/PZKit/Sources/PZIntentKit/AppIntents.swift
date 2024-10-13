// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation

// MARK: - SelectOnlyAccountIntent

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct SelectOnlyAccountIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectOnlyAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfileOnly"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var parameterSummary: some ParameterSummary {
        Summary()
    }

    @Parameter(title: "intent.field.localeProfile") public var account: AccountIntentAppEntity?

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectAccountIntent

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct SelectAccountIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var parameterSummary: some ParameterSummary {
        Summary()
    }

    @Parameter(title: "intent.field.localeProfile") public var accountIntent: AccountIntentAppEntity?

    @Parameter(title: "intent.field.useRandomWallpaper") public var randomBackground: Bool?

    @Parameter(title: "intent.field.wallpaper") public var background: [WidgetBackgroundAppEntity]?

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool?

    @Parameter(
        title: "intent.field.expeditionShowingMethod",
        default: .byNum
    ) public var expeditionShowingMethod: ExpeditionShowingMethodAppEnum?

    @Parameter(title: "intent.field.weeklyBossesShowingMethod", default: .neverShow)
    public var weeklyBossesShowingMethod: WeeklyBossesShowingMethodAppEnum?

    @Parameter(title: "intent.field.followSystemDarkMode", default: true) public var isDarkModeOn: Bool?

    @Parameter(
        title: "intent.field.showMaterialsInLargeSizeWidget",
        default: true
    ) public var showMaterialsInLargeSizeWidget: Bool?

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectAccountAndShowWhichInfoIntent

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public struct SelectAccountAndShowWhichInfoIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountAndShowWhichInfoIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfileWithExtraConfig"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var parameterSummary: some ParameterSummary {
        Summary()
    }

    @Parameter(title: "intent.field.localeProfile") public var account: AccountIntentAppEntity?

    @Parameter(title: "intent.field.showWeeklyBosses", default: true) public var showWeeklyBosses: Bool?

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool?

    @Parameter(title: "intent.field.staminaDisplayStyle", default: .byDefault)
    public var usingResinStyle: AutoRotationUsingResinWidgetStyleAppEnum?

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
