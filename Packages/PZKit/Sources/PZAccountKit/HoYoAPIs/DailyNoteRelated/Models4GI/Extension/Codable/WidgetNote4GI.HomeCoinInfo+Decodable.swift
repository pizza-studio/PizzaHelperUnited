// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension WidgetNote4GI.HomeCoinInfo4GI: Decodable {
    private enum CodingKeys: String, CodingKey {
        case maxHomeCoin = "max_home_coin"
        case currentHomeCoin = "current_home_coin"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxHomeCoin = try container.decode(Int.self, forKey: .maxHomeCoin)
        self.currentHomeCoin = try container.decode(Int.self, forKey: .currentHomeCoin)
        self.fullTime = Date(timeIntervalSinceNow: TimeInterval((maxHomeCoin - currentHomeCoin) * 120))
    }
}
