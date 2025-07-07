// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import GITodayMaterialsKit
import PZBaseKit
import PZInGameEventKit
import WidgetKit

// MARK: - MaterialWidgetEntry

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
public struct MaterialWidgetEntry: TimelineEntry, AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(events: [OfficialFeed.FeedEvent]?) {
        self.date = Date()
        self.materialWeekday = .today()
        let supplier = GITodayMaterial.Supplier(weekday: materialWeekday)
        self.talentMaterials = supplier.talentMaterials
        self.weaponMaterials = supplier.weaponMaterials
        self.events = events
    }

    // MARK: Public

    public let date: Date
    public let materialWeekday: GITodayMaterial.AvailableWeekDay?
    public let talentMaterials: [GITodayMaterial]
    public let weaponMaterials: [GITodayMaterial]
    public let events: [OfficialFeed.FeedEvent]?
}

// MARK: - OfficialFeedWidgetEntry

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
public struct OfficialFeedWidgetEntry: TimelineEntry, AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(games: Set<Pizza.SupportedGame>, events: [OfficialFeed.FeedEvent]?) {
        self.date = Date()
        self.events = events
        self.games = games
    }

    // MARK: Public

    public let date: Date
    public let events: [OfficialFeed.FeedEvent]?
    public let games: Set<Pizza.SupportedGame>
}

#endif
