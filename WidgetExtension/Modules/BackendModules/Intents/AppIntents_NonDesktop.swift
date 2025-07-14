// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit

// MARK: - PZEmbeddedIntent4ProfileOnly + WidgetConfigurationIntent

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZEmbeddedIntent4ProfileOnly: WidgetConfigurationIntent {}

// MARK: - PZEmbeddedIntent4ProfileOnly

// Only for watchOS and iOS_Lock_Screen.
@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
public struct PZEmbeddedIntent4ProfileOnly: AppIntent, CustomIntentMigratedAppIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectOnlyAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile4Peripherals"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.localProfile") public var account: AccountIntentAppEntity?

    public var showStaminaOnly: Bool { false }

    public var useTinyGlassDisplayStyle: Bool { false }

    public var showTransformer: Bool { false }

    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum { .neverShow }

    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum { .neverShow }

    public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum { .neverDisplay }

    public var randomBackground: Bool { false }

    public var chosenBackgrounds: [WidgetBackgroundAppEntity] { [] }

    public var isDarkModeRespected: Bool { true }

    public var showMaterialsInLargeSizeWidget: Bool { false }

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - PZEmbeddedIntent4ProfileMisc + WidgetConfigurationIntent

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZEmbeddedIntent4ProfileMisc: WidgetConfigurationIntent {}

// MARK: - PZEmbeddedIntent4ProfileMisc

// Only for watchOS and iOS_Lock_Screen.
@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
public struct PZEmbeddedIntent4ProfileMisc: AppIntent, CustomIntentMigratedAppIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountAndShowWhichInfoIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile4PeripheralsWithExtraConfig"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.localProfile") public var account: AccountIntentAppEntity?

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: true) public var showEchoOfWar: Bool

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: true) public var showTrounceBlossom: Bool

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    @Parameter(title: "intent.field.staminaDisplayStyle", default: .byDefault)
    public var usingResinStyle: StaminaContentRevolverStyleAppEnum

    public var showStaminaOnly: Bool { false }

    public var useTinyGlassDisplayStyle: Bool { false }

    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum {
        showTrounceBlossom ? .alwaysShow : .neverShow
    }

    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum { showEchoOfWar ? .alwaysShow : .neverShow }

    public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum { .displayWhenAvailable }

    public var randomBackground: Bool { false }

    public var chosenBackgrounds: [WidgetBackgroundAppEntity] { [] }

    public var isDarkModeRespected: Bool { true }

    public var showMaterialsInLargeSizeWidget: Bool { false }

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
