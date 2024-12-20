// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
typealias EventModel = OfficialFeed.FeedEvent

// MARK: - OfficialFeedWidgetEntry

@available(watchOS, unavailable)
struct OfficialFeedWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(game: Pizza.SupportedGame?, events: [EventModel]?) {
        self.date = Date()
        self.events = events
        self.game = game
    }

    // MARK: Internal

    let date: Date
    let events: [EventModel]?
    let game: Pizza.SupportedGame?
}

// MARK: - OfficialFeedWidgetProvider

@available(watchOS, unavailable)
struct OfficialFeedWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = OfficialFeedWidgetEntry
    typealias Intent = SelectOnlyGameIntent

    func recommendations() -> [AppIntentRecommendation<Intent>] { [] }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let game = configuration.game?.realValue
        let results = await OfficialFeed.getAllFeedEventsOnline().filter {
            switch game {
            case .none: true
            default: $0.game == configuration.game?.realValue
            }
        }
        if results.isEmpty {
            return .init(game: game, events: nil)
        } else {
            return .init(game: game, events: results)
        }
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let game = configuration.game?.realValue
        let results = await OfficialFeed.getAllFeedEventsOnline().filter {
            switch game {
            case .none: true
            default: $0.game == configuration.game?.realValue
            }
        }
        if results.isEmpty {
            return .init(
                entries: [.init(game: game, events: nil)],
                policy: .after(
                    Calendar.current
                        .date(byAdding: .hour, value: 1, to: Date())!
                )
            )
        } else {
            return .init(
                entries: [.init(game: game, events: .init(results))],
                policy: .after(
                    Calendar.current
                        .date(byAdding: .hour, value: 4, to: Date())!
                )
            )
        }
    }

    func placeholder(in context: Context) -> Entry {
        Entry(game: nil, events: nil)
    }
}
