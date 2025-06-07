// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - FullNote4GI.ExpeditionInfo4GI + Decodable

extension FullNote4GI.ExpeditionInfo4GI {
    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: .maxExpeditionsCount)
        self.expeditions = try container.decode(
            [FullNote4GI.ExpeditionInfo4GI.Expedition].self,
            forKey: .expeditions
        )
    }
}

// MARK: - FullNote4GI.ExpeditionInfo4GI.Expedition + Decodable

extension FullNote4GI.ExpeditionInfo4GI.Expedition {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<FullNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys> =
            try decoder
                .container(keyedBy: FullNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.self)
        if let timeIntervalUntilFinish = TimeInterval(try container.decode(
            String.self,
            forKey: FullNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.finishTime
        )) {
            self.finishTime = Date(timeIntervalSinceNow: timeIntervalUntilFinish)
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse time interval until finished expedition"
                )
            )
        }
        self.iconURL = try container.decode(
            URL.self,
            forKey: FullNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.iconURL
        )
    }

    private enum CodingKeys: String, CodingKey {
        case finishTime = "remained_time"
        case iconURL = "avatar_side_icon"
    }
}

// MARK: - FullNote4GI.ExpeditionInfo4GI + Encodable

extension FullNote4GI.ExpeditionInfo4GI {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxExpeditionsCount, forKey: .maxExpeditionsCount)
        try container.encode(expeditions, forKey: .expeditions)
    }
}

// MARK: - FullNote4GI.ExpeditionInfo4GI.Expedition + Encodable

extension FullNote4GI.ExpeditionInfo4GI.Expedition {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let remainedTime = finishTime.timeIntervalSinceNow
        let adjustedRemainedTime = remainedTime < 0 ? 0 : remainedTime
        try container.encode(String(Int(adjustedRemainedTime)), forKey: .finishTime)
        try container.encode(iconURL, forKey: .iconURL)
    }
}
