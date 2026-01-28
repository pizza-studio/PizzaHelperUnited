// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
@available(iOS 16.0, macCatalyst 16.0, *)
extension Defaults.Keys {
    public static let officialFeedMostRecentFetchDate = Key<[String: Date]>(
        "officialFeedMostRecentFetchDate",
        default: [:],
        suite: .baseSuite
    )

    public static let filterNonRegisteredGamesFromEventFeed = Key<Bool>(
        "filterNonRegisteredGamesFromEventFeed",
        default: false,
        suite: .baseSuite
    )
}
