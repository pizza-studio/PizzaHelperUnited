// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import WidgetKit

// MARK: - DualProfileWidgetEntry

@available(watchOS, unavailable)
public struct DualProfileWidgetEntry: TimelineEntry, Sendable {
    // MARK: Lifecycle

    public init(
        date: Date,
        resultSlot1: Result<any DailyNoteProtocol, any Error>,
        resultSlot2: Result<any DailyNoteProtocol, any Error>,
        viewConfig: WidgetViewConfig,
        profileSlot1: PZProfileSendable?,
        profileSlot2: PZProfileSendable?,
        pilotAssetMap: [URL: SendableImagePtr]? = nil,
        events: [OfficialFeed.FeedEvent]
    ) {
        self.date = date
        self.resultSlot1 = resultSlot1
        self.resultSlot2 = resultSlot2
        self.viewConfig = viewConfig
        self.profileSlot1 = profileSlot1
        self.profileSlot2 = profileSlot2
        self.events = events
        self.pilotAssetMap = pilotAssetMap ?? [:]
    }

    // MARK: Public

    public let date: Date
    public let timestampOnCreation: Date = .now
    public let resultSlot1: Result<any DailyNoteProtocol, any Error>
    public let resultSlot2: Result<any DailyNoteProtocol, any Error>
    public let viewConfig: WidgetViewConfig
    public let profileSlot1: PZProfileSendable?
    public let profileSlot2: PZProfileSendable?
    public let events: [OfficialFeed.FeedEvent]
    public let pilotAssetMap: [URL: SendableImagePtr]

    public var relevance: TimelineEntryRelevance? {
        .init(score: Swift.max(countRelevance(resultSlot1), countRelevance(resultSlot2)))
    }

    public func countRelevance(_ result: Result<any DailyNoteProtocol, any Error>) -> Float {
        switch result {
        case let .success(data):
            if data.staminaFullTimeOnFinish >= .now {
                return 10
            }
            let stamina = data.staminaIntel
            return 10 * Float(stamina.finished) / Float(stamina.all)
        case .failure:
            return 0
        }
    }
}

// MARK: - SingleProfileWidgetEntry

@available(watchOS, unavailable)
public struct SingleProfileWidgetEntry: TimelineEntry, Sendable {
    // MARK: Lifecycle

    public init(
        date: Date,
        result: Result<any DailyNoteProtocol, any Error>,
        viewConfig: WidgetViewConfig,
        profile: PZProfileSendable?,
        pilotAssetMap: [URL: SendableImagePtr]? = nil,
        events: [OfficialFeed.FeedEvent]
    ) {
        self.date = date
        self.result = result
        self.viewConfig = viewConfig
        self.profile = profile
        self.events = events
        self.pilotAssetMap = pilotAssetMap ?? [:]
    }

    // MARK: Public

    public let date: Date
    public let timestampOnCreation: Date = .now
    public let result: Result<any DailyNoteProtocol, any Error>
    public let viewConfig: WidgetViewConfig
    public let profile: PZProfileSendable?
    public let events: [OfficialFeed.FeedEvent]
    public let pilotAssetMap: [URL: SendableImagePtr]

    public var relevance: TimelineEntryRelevance? {
        switch result {
        case let .success(data):
            if data.staminaFullTimeOnFinish >= .now {
                return .init(score: 10)
            }
            let stamina = data.staminaIntel
            return .init(
                score: 10 * Float(stamina.finished) / Float(stamina.all)
            )
        case .failure:
            return .init(score: 0)
        }
    }
}
