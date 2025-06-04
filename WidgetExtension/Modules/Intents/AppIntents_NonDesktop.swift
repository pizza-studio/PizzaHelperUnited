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

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile4Peripherals"
    public static let description = IntentDescription("intent.description.pickTheLocalProfileForThisWidget")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(title: "intent.field.localeProfile") public var account: AccountIntentAppEntity?

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

    public static let title: LocalizedStringResource = "intent.name.selectLocalProfile4PeripheralsWithExtraConfig"
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
