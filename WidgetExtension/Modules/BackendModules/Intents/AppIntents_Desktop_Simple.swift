// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit

// MARK: - PZDesktopIntent4GameOnly + WidgetConfigurationIntent

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZDesktopIntent4GameOnly: WidgetConfigurationIntent {}

// MARK: - PZDesktopIntent4GameOnly

/// Used in those game-specifiable widgets irrelevant to a profile.
@available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
public struct PZDesktopIntent4GameOnly: AppIntent, CustomIntentMigratedAppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName: String = "SelectOnlyGameIntent"

    public static let title: LocalizedStringResource = "intent.name.selectGameOnly"
    public static let description = IntentDescription("intent.description.chooseTheGame")

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(
        title: "intent.field.game",
        default: WidgetSupportedGameAppEnum.allGames
    ) public var game: WidgetSupportedGameAppEnum

    @Parameter(title: "intent.field.inverseSelectMode", default: false) public var inverseSelectMode: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
