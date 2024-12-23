// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit

@available(watchOS, unavailable)
extension Defaults.Keys {
    public static let officialFeedCache = Key<[OfficialFeed.FeedEvent]>(
        "officialFeedCache",
        default: OfficialFeed.getAllBundledFeedEvents(),
        suite: .baseSuite
    )

    public static let officialFeedMostRecentFetchDate = Key<[String: Date]>(
        "officialFeedMostRecentFetchDate",
        default: [:],
        suite: .baseSuite
    )
}
