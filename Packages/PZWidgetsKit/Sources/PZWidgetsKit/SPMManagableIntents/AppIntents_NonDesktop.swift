// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit

// MARK: - PZEmbeddedIntent4ProfileOnly

// Only for watchOS and iOS_Lock_Screen.
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct PZEmbeddedIntent4ProfileOnly: AppIntent, CustomIntentMigratedAppIntent, WidgetConfigurationIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectOnlyAccountIntent"

    public static let title = LocalizedStringResource("intent.name.selectLocalProfile4Peripherals", bundle: .currentSPM)
    public static let description = IntentDescription(
        LocalizedStringResource("intent.description.pickTheLocalProfileForThisWidget", bundle: .currentSPM)
    )

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: LocalizedStringResource("intent.field.localProfile", bundle: .currentSPM))
    public var account: AccountIntentAppEntity?

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

// MARK: - PZEmbeddedIntent4ProfileMisc

// Only for watchOS and iOS_Lock_Screen.
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct PZEmbeddedIntent4ProfileMisc: AppIntent, CustomIntentMigratedAppIntent, WidgetConfigurationIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountAndShowWhichInfoIntent"

    public static let title = LocalizedStringResource(
        "intent.name.selectLocalProfile4PeripheralsWithExtraConfig",
        bundle: .currentSPM
    )
    public static let description = IntentDescription(
        LocalizedStringResource("intent.description.pickTheLocalProfileForThisWidget", bundle: .currentSPM)
    )

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: LocalizedStringResource("intent.field.localProfile", bundle: .currentSPM))
    public var account: AccountIntentAppEntity?

    @Parameter(
        title: LocalizedStringResource("intent.field.echoOfWarDisplayMethod", bundle: .currentSPM),
        default: true
    ) public var showEchoOfWar: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.trounceBlossomDisplayMethod", bundle: .currentSPM),
        default: true
    ) public var showTrounceBlossom: Bool

    @Parameter(title: LocalizedStringResource("intent.field.showTransformer", bundle: .currentSPM), default: true)
    public var showTransformer: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.staminaDisplayStyle", bundle: .currentSPM),
        default: .byDefault
    ) public var usingResinStyle: StaminaContentRevolverStyleAppEnum

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
