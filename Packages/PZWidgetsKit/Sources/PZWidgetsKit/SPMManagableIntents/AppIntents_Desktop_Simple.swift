// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit

// MARK: - PZDesktopIntent4GameOnly

/// Used in those game-specifiable widgets irrelevant to a profile.
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct PZDesktopIntent4GameOnly: AppIntent, CustomIntentMigratedAppIntent, WidgetConfigurationIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let intentClassName: String = "SelectOnlyGameIntent"

    public static let title = LocalizedStringResource("intent.name.selectGameOnly", bundle: .currentSPM)
    public static let description = IntentDescription(
        LocalizedStringResource("intent.description.chooseTheGame", bundle: .currentSPM)
    )

    public static var isDiscoverable: Bool { false }

    public static var parameterSummary: some ParameterSummary { Summary() }

    @Parameter(
        title: LocalizedStringResource("intent.field.game", bundle: .currentSPM),
        default: WidgetSupportedGameAppEnum.allGames
    ) public var game: WidgetSupportedGameAppEnum

    @Parameter(title: LocalizedStringResource("intent.field.inverseSelectMode", bundle: .currentSPM), default: false)
    public var inverseSelectMode: Bool

    public func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        .result()
    }
}
