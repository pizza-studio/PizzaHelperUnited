// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

/// Daily Note Metadata. Unavailable if daily note is fetched from Widget API.
public struct NoteMetaData4HSR: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.currentTs = try container.decode(Int.self, forKey: .currentTs)
        self.signURL = try container.decode(URL.self, forKey: .signURL)
        self.homeURL = try container.decode(URL.self, forKey: .homeURL)
        self.noteURL = try container.decode(URL.self, forKey: .noteURL)
    }

    // MARK: Public

    public let currentTs: Int
    public let signURL: URL
    public let homeURL: URL
    public let noteURL: URL

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(currentTs, forKey: .currentTs)
        try container.encode(signURL, forKey: .signURL)
        try container.encode(homeURL, forKey: .homeURL)
        try container.encode(noteURL, forKey: .noteURL)
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case currentTs = "current_ts"
        case signURL = "sign_url"
        case homeURL = "home_url"
        case noteURL = "note_url"
    }
}
