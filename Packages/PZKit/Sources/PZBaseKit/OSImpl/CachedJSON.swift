// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

// MARK: - CachedJSON

public struct CachedJSON: AbleToCodeSendHash, Defaults.Serializable {
    // MARK: Lifecycle

    public init(rawJSONString: String, timestamp: TimeInterval? = nil) {
        self.rawJSONString = rawJSONString
        self.timestamp = timestamp ?? Date().timeIntervalSince1970
    }

    // MARK: Public

    public let rawJSONString: String
    public let timestamp: TimeInterval

    public var cachedTime: Date { .init(timeIntervalSince1970: timestamp) }
}
