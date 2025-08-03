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

// MARK: - MaterialWidgetProvider

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct MaterialWidgetProvider: TimelineProvider {
    typealias Entry = MaterialWidgetEntry

    func placeholder(in context: Context) -> Entry {
        .init(
            events: Defaults[.officialFeedCache].filter {
                $0.game == .genshinImpact
            }
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (MaterialWidgetEntry) -> Void
    ) {
        Task {
            var results: [OfficialFeed.FeedEvent]? = Defaults[.officialFeedCache].filter {
                $0.game == .genshinImpact
            }
            let isEmpty = results?.isEmpty ?? true
            if isEmpty { results = nil }
            let entry = Entry(events: results)
            completion(entry)
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<MaterialWidgetEntry>) -> Void
    ) {
        Task {
            var results: [OfficialFeed.FeedEvent]? = await OfficialFeed.getAllFeedEventsOnline(game: .genshinImpact)
            let isEmpty = results?.isEmpty ?? true
            if isEmpty { results = nil }
            let entry = Entry(events: results)
            let policyAfterTime = Calendar.gregorian.date(
                byAdding: .hour, value: isEmpty ? 1 : 4, to: Date()
            )!
            completion(
                .init(
                    entries: [entry],
                    policy: .after(policyAfterTime)
                )
            )
        }
    }
}

#endif
