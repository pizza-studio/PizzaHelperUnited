// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Defaults
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - OfficialFeedWidgetProvider

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
extension OfficialFeedWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PZWidgetsKit.OfficialFeedWidgetEntry {
        Entry(games: .init(Pizza.SupportedGame.allCases), events: Defaults[.officialFeedCache])
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct OfficialFeedWidgetProvider: CrossGenServiceableTimelineProvider {
    typealias Entry = OfficialFeedWidgetEntry
    typealias Intent = PZDesktopIntent4GameOnly

    func placeholder() -> Entry {
        Entry(games: .init(Pizza.SupportedGame.allCases), events: Defaults[.officialFeedCache])
    }

    func snapshot(for configuration: Intent) async -> Entry {
        let game = configuration.game.realValue
        let games = configuration.inverseSelectMode
            ? configuration.game.inverseSelectedValues
            : [game].compactMap { $0 }
        var results: [OfficialFeed.FeedEvent]? = Defaults[.officialFeedCache].filter {
            switch game {
            case .none: true
            default: games.contains($0.game)
            }
        }
        let isEmpty = results?.isEmpty ?? true
        if isEmpty { results = nil }
        var entry = Entry(games: .init(games), events: results)
        await updateEntryViewConfig(&entry, games: games)
        return entry
    }

    func timeline(for configuration: Intent) async -> Timeline<Entry> {
        let game = configuration.game.realValue
        let games = configuration.inverseSelectMode
            ? configuration.game.inverseSelectedValues
            : [game].compactMap { $0 }
        var results: [OfficialFeed.FeedEvent]? = await Task(priority: .userInitiated) {
            await OfficialFeed.getAllFeedEventsOnline().filter {
                switch game {
                case .none: true
                default: games.contains($0.game)
                }
            }
        }.value
        let isEmpty = results?.isEmpty ?? true
        if isEmpty { results = nil }
        var entry = Entry(games: .init(games), events: results)
        await updateEntryViewConfig(&entry, games: games)
        let policyAfterTime = Calendar.gregorian.date(
            byAdding: .hour, value: isEmpty ? 1 : 4, to: Date()
        )!
        return
            .init(
                entries: [entry],
                policy: .after(policyAfterTime)
            )
    }

    func updateEntryViewConfig(_ entry: inout Entry, games: [Pizza.SupportedGame]) async {
        entry.viewConfig.isDarkModeRespected = true
        entry.viewConfig.randomBackground = false
        entry.viewConfig.selectedBackgrounds = [
            WidgetBackground.randomWallpaperBackground4Games(Set(games)),
        ]
        entry.viewConfig.updateBackgroundValue()
        await entry.viewConfig.saveOnlineBackgroundAsset()
    }
}

#endif
