// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
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

    init(games: Set<Pizza.SupportedGame>, events: [EventModel]?) {
        self.date = Date()
        self.events = events
        self.games = games
    }

    // MARK: Internal

    let date: Date
    let events: [EventModel]?
    let games: Set<Pizza.SupportedGame>
}

// MARK: - OfficialFeedWidgetProvider

@available(watchOS, unavailable)
struct OfficialFeedWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = OfficialFeedWidgetEntry
    typealias Intent = SelectOnlyGameIntent

    func recommendations() -> [AppIntentRecommendation<Intent>] { [] }

    func placeholder(in context: Context) -> Entry {
        Entry(games: .init(Pizza.SupportedGame.allCases), events: Defaults[.officialFeedCache])
    }

    func snapshot(for configuration: Intent, in context: Context) async -> Entry {
        let game = configuration.game.realValue
        let games = configuration.inverseSelectMode
            ? configuration.game.inverseSelectedValues
            : [game].compactMap { $0 }
        let results = Defaults[.officialFeedCache].filter {
            switch game {
            case .none: true
            default: games.contains($0.game)
            }
        }
        if results.isEmpty {
            return .init(games: .init(games), events: nil)
        } else {
            return .init(games: .init(games), events: results)
        }
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        let game = configuration.game.realValue
        let games = configuration.inverseSelectMode
            ? configuration.game.inverseSelectedValues
            : [game].compactMap { $0 }
        let results = await Task(priority: .userInitiated) {
            await OfficialFeed.getAllFeedEventsOnline().filter {
                switch game {
                case .none: true
                default: games.contains($0.game)
                }
            }
        }.value
        if results.isEmpty {
            return .init(
                entries: [.init(games: .init(games), events: nil)],
                policy: .after(
                    Calendar.gregorian
                        .date(byAdding: .hour, value: 1, to: Date())!
                )
            )
        } else {
            return .init(
                entries: [.init(games: .init(games), events: .init(results))],
                policy: .after(
                    Calendar.gregorian
                        .date(byAdding: .hour, value: 4, to: Date())!
                )
            )
        }
    }
}
