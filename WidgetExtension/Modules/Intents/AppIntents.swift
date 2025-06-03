// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit

// MARK: - SelectOnlyAccountIntent

// Only for watchOS and iOS_Lock_Screen.
public struct SelectOnlyAccountIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectOnlyAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfileOnly"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.localeProfile") public var account: AccountIntentAppEntity?

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectProfileIntentProtocol

public protocol SelectProfileIntentProtocol {
    var showTransformer: Bool { get set }
    var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum { get set }
    var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum { get set }
    var randomBackground: Bool { get set }
    var chosenBackgrounds: [WidgetBackgroundAppEntity] { get set }
    var isDarkModeRespected: Bool { get set }
    var showMaterialsInLargeSizeWidget: Bool { get set }
}

// MARK: - SelectAccountIntent

// Only for iOS Springboard Widgets and macOS Desktop Widgets.
public struct SelectAccountIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent,
    SelectProfileIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary {
        When(\.$randomBackground, .equalTo, true) {
            // Omitting `chosenBackgrounds`.
            Summary {
                \.$accountIntent
                \.$randomBackground
                \.$isDarkModeRespected
                \.$echoOfWarDisplayMethod
                \.$trounceBlossomDisplayMethod
                \.$showTransformer
                \.$showMaterialsInLargeSizeWidget
            }
        } otherwise: {
            Summary()
        }
    }

    @Parameter(title: "intent.field.localeProfile") public var accountIntent: AccountIntentAppEntity?

    @Parameter(title: "intent.field.useRandomWallpaper", default: false) public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: "intent.field.wallpaper", default: []) public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: "intent.field.followSystemDarkMode", default: true) public var isDarkModeRespected: Bool

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: .alwaysShow)
    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: .alwaysShow)
    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    @Parameter(
        title: "intent.field.showMaterialsInLargeSizeWidget",
        default: true
    ) public var showMaterialsInLargeSizeWidget: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectDualProfileIntent

// Only for iOS Springboard Widgets and macOS Desktop Widgets.
// 该 Intent 允许指定两个本地帐号。
public struct SelectDualProfileIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent,
    SelectProfileIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectDualProfileIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfileDuo"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileDuoForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary {
        When(\.$randomBackground, .equalTo, true) {
            // Omitting `chosenBackgrounds`.
            Summary {
                \.$profileSlot1
                \.$profileSlot2
                \.$randomBackground
                \.$isDarkModeRespected
                \.$echoOfWarDisplayMethod
                \.$trounceBlossomDisplayMethod
                \.$showTransformer
                \.$showMaterialsInLargeSizeWidget
            }
        } otherwise: {
            Summary()
        }
    }

    @Parameter(title: "intent.field.localeProfile.slot1") public var profileSlot1: AccountIntentAppEntity?
    @Parameter(title: "intent.field.localeProfile.slot2") public var profileSlot2: AccountIntentAppEntity?

    @Parameter(title: "intent.field.useRandomWallpaper", default: false) public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: "intent.field.wallpaper", default: []) public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: "intent.field.followSystemDarkMode", default: true) public var isDarkModeRespected: Bool

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: .alwaysShow)
    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: .alwaysShow)
    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    @Parameter(
        title: "intent.field.showMaterialsInLargeSizeWidget",
        default: true
    ) public var showMaterialsInLargeSizeWidget: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectAccountAndShowWhichInfoIntent

// Only for watchOS and iOS_Lock_Screen.
public struct SelectAccountAndShowWhichInfoIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountAndShowWhichInfoIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfileWithExtraConfig"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.localeProfile") public var account: AccountIntentAppEntity?

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: true) public var showEchoOfWar: Bool

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: true) public var showTrounceBlossom: Bool

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    @Parameter(title: "intent.field.staminaDisplayStyle", default: .byDefault)
    public var usingResinStyle: AutoRotationUsingResinWidgetStyleAppEnum

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - SelectOnlyGameIntent

public struct SelectOnlyGameIntent: AppIntent, WidgetConfigurationIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let title: LocalizedStringResource = "intent.name.selectGameOnly"
    public static let description = IntentDescription("intent.description.chooseTheGame")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.game", default: WidgetSupportedGame.allGames) public var game: WidgetSupportedGame

    @Parameter(title: "intent.field.inverseSelectMode", default: false) public var inverseSelectMode: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - WidgetRefreshIntent

@available(watchOS, unavailable)
public struct WidgetRefreshIntent: AppIntent {
    // MARK: Lifecycle

    public init() {}

    public init(dailyNoteUIDWithGame: String?) {
        self.dailyNoteUIDWithGame = dailyNoteUIDWithGame
    }

    // MARK: Public

    public static let title: LocalizedStringResource = "pzWidgetsKit.WidgetRefreshIntent.Refresh"

    public static var isDiscoverable: Bool { false }

    public var dailyNoteUIDWithGame: String?

    public func perform() async throws -> some IntentResult {
        if let dailyNoteUIDWithGame {
            Defaults[.cachedDailyNotes].removeValue(forKey: dailyNoteUIDWithGame)
        }
        return .result()
    }
}
