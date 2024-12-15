// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension WidgetNote4GI.ResinInfo4GI: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxResin = try container.decode(Int.self, forKey: .maxResin)
        self.currentResin = try container.decode(Int.self, forKey: .currentResin)
        if let resinRecoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .resinRecoveryTime)) {
            self.resinRecoveryTime = Date(timeInterval: resinRecoveryTimeInterval, since: .now)
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse time interval of resin recovery time"
                )
            )
        }
    }

    private enum CodingKeys: String, CodingKey {
        case maxResin = "max_resin"
        case currentResin = "current_resin"
        case resinRecoveryTime = "resin_recovery_time"
    }
}
