// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit

// MARK: - SelectOnlyGameIntent

/// Used in those game-specifiable widgets irrelevant to a profile.
@available(iOS 16.2, macCatalyst 16.2, *)
public struct SelectOnlyGameIntent: AppIntent, WidgetConfigurationIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

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
