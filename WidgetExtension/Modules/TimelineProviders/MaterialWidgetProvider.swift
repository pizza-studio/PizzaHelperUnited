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
typealias MaterialWeekday = GITodayMaterial.AvailableWeekDay

// MARK: - MaterialWidgetEntry

@available(watchOS, unavailable)
struct MaterialWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(events: [EventModel]?) {
        self.date = Date()
        self.materialWeekday = .today()
        let supplier = GITodayMaterial.Supplier(weekday: materialWeekday)
        self.talentMaterials = supplier.talentMaterials
        self.weaponMaterials = supplier.weaponMaterials
        self.events = events
    }

    // MARK: Internal

    let date: Date
    let materialWeekday: MaterialWeekday?
    let talentMaterials: [GITodayMaterial]
    let weaponMaterials: [GITodayMaterial]
    let events: [EventModel]?
}

// MARK: - MaterialWidgetProvider

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
            let results = Defaults[.officialFeedCache].filter {
                $0.game == .genshinImpact
            }
            if results.isEmpty {
                completion(.init(events: nil))
            } else {
                completion(.init(events: results))
            }
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<MaterialWidgetEntry>) -> Void
    ) {
        Task {
            let results = await OfficialFeed.getAllFeedEventsOnline(game: .genshinImpact)
            if results.isEmpty {
                completion(
                    .init(
                        entries: [.init(events: nil)],
                        policy: .after(
                            Calendar.gregorian
                                .date(byAdding: .hour, value: 1, to: Date())!
                        )
                    )
                )
            } else {
                completion(.init(
                    entries: [.init(events: .init(results))],
                    policy: .after(
                        Calendar.gregorian
                            .date(byAdding: .hour, value: 4, to: Date())!
                    )
                ))
            }
        }
    }
}
