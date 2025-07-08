// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit

// MARK: - ProfileWidgetIntentProtocol

@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
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

// MARK: - PZDesktopIntent4SingleProfile + WidgetConfigurationIntent

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension PZDesktopIntent4SingleProfile: WidgetConfigurationIntent {}

// MARK: - PZDesktopIntent4SingleProfile

@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
public struct PZDesktopIntent4SingleProfile: AppIntent, CustomIntentMigratedAppIntent,
    ProfileWidgetIntentProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName = "SelectAccountIntent"

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

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
                    \.$expeditionDisplayPolicy
                }
            } otherwise: {
                Summary {
                    \.$accountIntent
                    \.$randomBackground
                    \.$chosenBackgrounds
                    \.$isDarkModeRespected
                    \.$showStaminaOnly
                    \.$useTinyGlassDisplayStyle
                    \.$expeditionDisplayPolicy
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

    @Parameter(title: "intent.field.localProfile") public var accountIntent: AccountIntentAppEntity?

    @Parameter(title: "intent.field.useRandomWallpaper", default: false) public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: "intent.field.wallpaper", default: []) public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: "intent.field.followSystemDarkMode", default: true) public var isDarkModeRespected: Bool

    @Parameter(title: "intent.field.useTinyGlassDisplayStyle", default: false) public var useTinyGlassDisplayStyle: Bool

    @Parameter(title: "intent.field.showStaminaOnly", default: false) public var showStaminaOnly: Bool

    @Parameter(title: "intent.field.expeditionDisplayPolicy", default: .displayWhenAvailable)
    public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum

    @Parameter(title: "intent.field.showMaterialsInLargeSizeWidget", default: true)
    public var showMaterialsInLargeSizeWidget: Bool

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: .alwaysShow)
    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: .alwaysShow)
    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}

// MARK: - PZDesktopIntent4DualProfiles + WidgetConfigurationIntent

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension PZDesktopIntent4DualProfiles: WidgetConfigurationIntent {}

// MARK: - PZDesktopIntent4DualProfiles

// Only for iOS Springboard Widgets and macOS Desktop Widgets.
// 该 Intent 允许指定两个本地帐号。

@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
public struct PZDesktopIntent4DualProfiles: AppIntent, CustomIntentMigratedAppIntent,
    ProfileWidgetIntentProtocol {
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

    @Parameter(title: "intent.field.localProfile.slot1") public var profileSlot1: AccountIntentAppEntity?

    @Parameter(title: "intent.field.localProfile.slot2") public var profileSlot2: AccountIntentAppEntity?

    @Parameter(title: "intent.field.useRandomWallpaper", default: false) public var randomBackground: Bool

    /// This property, as an array with typed contents, is not inheritable from SiriKit Intents.
    /// If not changing the field name to a new one, the previous data will hinder this property
    /// from being configured by the user. Hence the change from `background` to `chosenBackgrounds`.
    @Parameter(title: "intent.field.wallpaper", default: []) public var chosenBackgrounds: [WidgetBackgroundAppEntity]

    @Parameter(title: "intent.field.followSystemDarkMode", default: true) public var isDarkModeRespected: Bool

    @Parameter(title: "intent.field.useTinyGlassDisplayStyle", default: false) public var useTinyGlassDisplayStyle: Bool

    @Parameter(title: "intent.field.expeditionDisplayPolicy", default: .displayWhenAvailable)
    public var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum

    @Parameter(title: "intent.field.echoOfWarDisplayMethod", default: .alwaysShow)
    public var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.trounceBlossomDisplayMethod", default: .alwaysShow)
    public var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum

    @Parameter(title: "intent.field.showTransformer", default: true) public var showTransformer: Bool

    public var showMaterialsInLargeSizeWidget: Bool { false }

    public var showStaminaOnly: Bool { false }

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
