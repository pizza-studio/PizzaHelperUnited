// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit

// MARK: - ProfileWidgetIntentProtocol

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public protocol ProfileWidgetIntentProtocol {
    var showStaminaOnly: Bool { get }
    var useTinyGlassDisplayStyle: Bool { get }
    var showTransformer: Bool { get }
    var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum { get }
    var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum { get }
    var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum { get }
    var randomBackground: Bool { get }
    var chosenBackgrounds: [WidgetBackgroundAppEntity] { get }
    var isDarkModeRespected: Bool { get }
    var showMaterialsInLargeSizeWidget: Bool { get }
}

// MARK: - PZDesktopIntent4SingleProfile

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct PZDesktopIntent4SingleProfile: AppIntent, CustomIntentMigratedAppIntent, WidgetConfigurationIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountIntent"

    public static let title = LocalizedStringResource("intent.name.selectLocalProfile", bundle: .currentSPM)
    public static let description = IntentDescription(
        LocalizedStringResource("intent.description.pickTheLocalProfileForThisWidget", bundle: .currentSPM)
    )

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary {
        When(\.$showStaminaOnly, .equalTo, true) {
            When(\.$randomBackground, .equalTo, true) {
                // Omitting `chosenBackgrounds`.
                Summary {
                    \.$accountIntent
                    \.$randomBackground
                    \.$isDarkModeRespected
                    \.$showStaminaOnly
                    \.$useTinyGlassDisplayStyle
                }
            } otherwise: {
                Summary {
                    \.$accountIntent
                    \.$randomBackground
                    \.$chosenBackgrounds
                    \.$isDarkModeRespected
                    \.$showStaminaOnly
                    \.$useTinyGlassDisplayStyle
                }
            }
        } otherwise: {
            When(\.$randomBackground, .equalTo, true) {
                // Omitting `chosenBackgrounds`.
                Summary {
                    \.$accountIntent
                    \.$randomBackground
                    \.$isDarkModeRespected
                    \.$showStaminaOnly
                    \.$useTinyGlassDisplayStyle
                    \.$expeditionDisplayPolicy
                    \.$showMaterialsInLargeSizeWidget
                    \.$echoOfWarDisplayMethod
                    \.$trounceBlossomDisplayMethod
                    \.$showTransformer
                }
            } otherwise: {
                Summary()
            }
        }
    }

    @Parameter(title: LocalizedStringResource("intent.field.localProfile", bundle: .currentSPM))
    public var accountIntent: AccountIntentAppEntity?

    @Parameter(title: LocalizedStringResource("intent.field.useRandomWallpaper", bundle: .currentSPM), default: false)
    public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: LocalizedStringResource("intent.field.wallpaper", bundle: .currentSPM), default: [])
    public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: LocalizedStringResource("intent.field.followSystemDarkMode", bundle: .currentSPM), default: true)
    public var isDarkModeRespected: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.useTinyGlassDisplayStyle", bundle: .currentSPM),
        default: false
    ) public var useTinyGlassDisplayStyle: Bool

    @Parameter(title: LocalizedStringResource("intent.field.showStaminaOnly", bundle: .currentSPM), default: false)
    public var showStaminaOnly: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.expeditionDisplayPolicy", bundle: .currentSPM),
        default: .displayWhenAvailable
    ) public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum

    @Parameter(
        title: LocalizedStringResource("intent.field.showMaterialsInLargeSizeWidget", bundle: .currentSPM),
        default: true
    ) public var showMaterialsInLargeSizeWidget: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.echoOfWarDisplayMethod", bundle: .currentSPM),
        default: .alwaysShow
    ) public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(
        title: LocalizedStringResource("intent.field.trounceBlossomDisplayMethod", bundle: .currentSPM),
        default: .alwaysShow
    ) public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: LocalizedStringResource("intent.field.showTransformer", bundle: .currentSPM), default: true)
    public var showTransformer: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - PZDesktopIntent4DualProfiles

// Only for iOS Springboard Widgets and macOS Desktop Widgets.
// 该 Intent 允许指定两个本地帐号。

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct PZDesktopIntent4DualProfiles: AppIntent, CustomIntentMigratedAppIntent, WidgetConfigurationIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectDualProfileIntent"

    public static let title = LocalizedStringResource("intent.name.selectLocalProfileDuo", bundle: .currentSPM)
    public static let description = IntentDescription(
        LocalizedStringResource("intent.description.pickTheLocalProfileDuoForThisWidget", bundle: .currentSPM)
    )

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary {
        When(\.$randomBackground, .equalTo, true) {
            // Omitting `chosenBackgrounds`.
            Summary {
                \.$profileSlot1
                \.$profileSlot2
                \.$randomBackground
                \.$isDarkModeRespected
                \.$useTinyGlassDisplayStyle
                \.$expeditionDisplayPolicy
                \.$echoOfWarDisplayMethod
                \.$trounceBlossomDisplayMethod
                \.$showTransformer
            }
        } otherwise: {
            Summary()
        }
    }

    @Parameter(title: LocalizedStringResource("intent.field.localProfile.slot1", bundle: .currentSPM))
    public var profileSlot1: AccountIntentAppEntity?

    @Parameter(title: LocalizedStringResource("intent.field.localProfile.slot2", bundle: .currentSPM))
    public var profileSlot2: AccountIntentAppEntity?

    @Parameter(title: LocalizedStringResource("intent.field.useRandomWallpaper", bundle: .currentSPM), default: false)
    public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: LocalizedStringResource("intent.field.wallpaper", bundle: .currentSPM), default: [])
    public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: LocalizedStringResource("intent.field.followSystemDarkMode", bundle: .currentSPM), default: true)
    public var isDarkModeRespected: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.useTinyGlassDisplayStyle", bundle: .currentSPM),
        default: false
    ) public var useTinyGlassDisplayStyle: Bool

    @Parameter(
        title: LocalizedStringResource("intent.field.expeditionDisplayPolicy", bundle: .currentSPM),
        default: .displayWhenAvailable
    ) public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum

    @Parameter(
        title: LocalizedStringResource("intent.field.echoOfWarDisplayMethod", bundle: .currentSPM),
        default: .alwaysShow
    ) public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(
        title: LocalizedStringResource("intent.field.trounceBlossomDisplayMethod", bundle: .currentSPM),
        default: .alwaysShow
    ) public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: LocalizedStringResource("intent.field.showTransformer", bundle: .currentSPM), default: true)
    public var showTransformer: Bool

    public var showMaterialsInLargeSizeWidget: Bool { false }

    public var showStaminaOnly: Bool { false }

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
