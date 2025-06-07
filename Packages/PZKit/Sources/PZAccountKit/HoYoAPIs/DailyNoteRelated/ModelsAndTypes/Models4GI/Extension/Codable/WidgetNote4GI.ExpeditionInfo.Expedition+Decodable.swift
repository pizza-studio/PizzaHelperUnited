// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - WidgetNote4GI.ExpeditionInfo4GI.Expedition + Decodable

extension WidgetNote4GI.ExpeditionInfo4GI.Expedition: Decodable {
    enum CodingKeys: String, CodingKey {
        case status
        case iconURL = "avatar_side_icon"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decode(String.self, forKey: CodingKeys.status) == "Finished" {
            self.isFinished = true
        } else {
            self.isFinished = false
        }
        self.iconURL = try container.decode(URL.self, forKey: CodingKeys.iconURL)
    }
}

// MARK: - WidgetNote4GI.ExpeditionInfo4GI + Decodable

extension WidgetNote4GI.ExpeditionInfo4GI: Decodable {
    enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: CodingKeys.maxExpeditionsCount)
        self.expeditions = try container.decode(
            [WidgetNote4GI.ExpeditionInfo4GI.Expedition].self,
            forKey: CodingKeys.expeditions
        )
    }
}

// MARK: - WidgetNote4GI.ExpeditionInfo4GI.Expedition + Encodable

extension WidgetNote4GI.ExpeditionInfo4GI.Expedition: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isFinished ? "Finished" : "Ongoing", forKey: .status)
        try container.encode(iconURL, forKey: .iconURL)
    }
}

// MARK: - WidgetNote4GI.ExpeditionInfo4GI + Encodable

extension WidgetNote4GI.ExpeditionInfo4GI: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxExpeditionsCount, forKey: .maxExpeditionsCount)
        try container.encode(expeditions, forKey: .expeditions)
    }
}
