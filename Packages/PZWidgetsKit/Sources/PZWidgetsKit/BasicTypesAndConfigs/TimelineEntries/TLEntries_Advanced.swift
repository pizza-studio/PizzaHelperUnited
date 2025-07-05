// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import WidgetKit

// MARK: - ProfileWidgetEntry

/// 这是（无论系统平台的）任何需要配置本地帐号的小工具所共用的 TimelineEntry 类型。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public struct ProfileWidgetEntry: TimelineEntry, Sendable {
    // MARK: Lifecycle

    public init(
        date: Date,
        result: Result<any DailyNoteProtocol, any Error>,
        viewConfig: WidgetViewConfig,
        profile: PZProfileSendable?,
        pilotAssetMap: [URL: SendableImagePtr]? = nil,
        events: [OfficialFeed.FeedEvent] = []
    ) {
        self.date = date
        self.resultSlot1 = result
        self.resultSlot2 = .failure(Self.secondarySlotIntentionallyBlankException)
        self.viewConfig = viewConfig
        self.profileSlot1 = profile
        self.profileSlot2 = nil
        self.events = events
        self.pilotAssetMap = pilotAssetMap ?? [:]
    }

    public init(
        date: Date,
        resultSlot1: Result<any DailyNoteProtocol, any Error>,
        resultSlot2: Result<any DailyNoteProtocol, any Error>?,
        viewConfig: WidgetViewConfig,
        profileSlot1: PZProfileSendable?,
        profileSlot2: PZProfileSendable?,
        pilotAssetMap: [URL: SendableImagePtr]? = nil,
        events: [OfficialFeed.FeedEvent]
    ) {
        self.date = date
        self.resultSlot1 = resultSlot1
        self.resultSlot2 = resultSlot2 ?? .failure(Self.secondarySlotIntentionallyBlankException)
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

    /// An API for compatibility purposes. This only returns the slot 1.
    public var result: Result<any DailyNoteProtocol, any Error> {
        resultSlot1
    }

    /// An API for compatibility purposes. This only returns the slot 1.
    public var profile: PZProfileSendable? {
        profileSlot1
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

    // MARK: Private

    private static var secondarySlotIntentionallyBlankException: Error {
        NSError(
            domain: "ProfileWidgetEntry",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: "The 2nd profile result slot is intentionally left nil.",
            ]
        )
    }
}

// MARK: Hashable, Identifiable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension ProfileWidgetEntry: Hashable, Identifiable {
    public static func == (lhs: ProfileWidgetEntry, rhs: ProfileWidgetEntry) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public var id: Int { hashValue }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(timestampOnCreation)
        hasher.combine(viewConfig)
        hasher.combine(profileSlot1)
        hasher.combine(profileSlot2)
        hasher.combine(events)
        switch resultSlot1 {
        case let .success(note):
            hasher.combine(note)
        case let .failure(error):
            hasher.combine("\(error)")
        }
        switch resultSlot2 {
        case let .success(note):
            hasher.combine(note)
        case let .failure(error):
            hasher.combine("\(error)")
        }
    }
}
