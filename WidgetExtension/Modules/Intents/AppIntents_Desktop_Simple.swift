// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Foundation
import PZBaseKit

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

// MARK: - SelectOnlyGameIntent

/// Used in those game-specifiable widgets irrelevant to a profile.
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
