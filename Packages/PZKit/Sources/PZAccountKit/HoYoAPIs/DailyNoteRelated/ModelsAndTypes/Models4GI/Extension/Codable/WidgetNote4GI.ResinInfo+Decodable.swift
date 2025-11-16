// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - WidgetNote4GI.ResinInfo4GI + Decodable

extension WidgetNote4GI.ResinInfo4GI: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxResin = try container.decode(Int.self, forKey: .maxResin)
        self.currentResin = try container.decode(Int.self, forKey: .currentResin)
        if let resinRecoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .resinRecoveryTime)) {
            self.resinRecoveryTime = Date(timeInterval: resinRecoveryTimeInterval, since: .init())
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

// MARK: - WidgetNote4GI.ResinInfo4GI + Encodable

extension WidgetNote4GI.ResinInfo4GI: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxResin, forKey: .maxResin)
        try container.encode(currentResin, forKey: .currentResin)
        let interval = resinRecoveryTime.timeIntervalSinceNow
        let encodedInterval = interval.asIntIfFinite() ?? 0
        try container.encode(String(encodedInterval), forKey: .resinRecoveryTime)
    }
}
