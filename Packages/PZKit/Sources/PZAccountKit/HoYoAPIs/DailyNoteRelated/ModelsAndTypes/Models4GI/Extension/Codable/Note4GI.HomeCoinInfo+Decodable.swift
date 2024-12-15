// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - HomeCoinInfo4GI

// MARK: Decodable

extension GeneralNote4GI.HomeCoinInfo4GI: Decodable {
    private enum CodingKeys: String, CodingKey {
        case maxHomeCoin = "max_home_coin"
        case currentHomeCoin = "current_home_coin"
        case homeCoinRecoveryTime = "home_coin_recovery_time"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxHomeCoin = try container.decode(Int.self, forKey: .maxHomeCoin)
        self.currentHomeCoin = try container.decode(Int.self, forKey: .currentHomeCoin)
        if let recoveryTimeInterval = TimeInterval(try container.decode(String.self, forKey: .homeCoinRecoveryTime)) {
            self.fullTime = Date(timeIntervalSinceNow: recoveryTimeInterval)
        } else {
            throw DecodingError.typeMismatch(
                TimeInterval.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to parse home coint recovery time interval"
                )
            )
        }
    }
}
