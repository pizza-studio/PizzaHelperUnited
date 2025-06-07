// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import PZBaseKit

/// I don't know why the fuck this one can be put in a Swift Package without a fucking problem.
/// Maybe the limitation doesn't hinder this intent to be triggered in a view it gets embedded in.
@available(watchOS, unavailable)
public struct WidgetRefreshIntent: AppIntent, WidgetRefreshIntentProtocol {
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
