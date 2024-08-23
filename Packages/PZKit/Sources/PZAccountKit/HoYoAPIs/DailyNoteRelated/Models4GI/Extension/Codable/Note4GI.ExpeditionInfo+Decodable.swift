// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GeneralNote4GI.ExpeditionInfo4GI + Decodable

extension GeneralNote4GI.ExpeditionInfo4GI: Decodable {
    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case maxExpeditionsCount = "max_expedition_num"
        case expeditions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxExpeditionsCount = try container.decode(Int.self, forKey: .maxExpeditionsCount)
        self.expeditions = try container.decode(
            [GeneralNote4GI.ExpeditionInfo4GI.Expedition].self,
            forKey: .expeditions
        )
    }
}

// MARK: - GeneralNote4GI.ExpeditionInfo4GI.Expedition + Decodable

extension GeneralNote4GI.ExpeditionInfo4GI.Expedition: Decodable {
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<GeneralNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys> =
            try decoder
                .container(keyedBy: GeneralNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.self)
        if let timeIntervalUntilFinish = TimeInterval(try container.decode(
            String.self,
            forKey: GeneralNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.finishTime
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
            forKey: GeneralNote4GI.ExpeditionInfo4GI.Expedition.CodingKeys.iconURL
        )
    }

    private enum CodingKeys: String, CodingKey {
        case finishTime = "remained_time"
        case iconURL = "avatar_side_icon"
    }
}
