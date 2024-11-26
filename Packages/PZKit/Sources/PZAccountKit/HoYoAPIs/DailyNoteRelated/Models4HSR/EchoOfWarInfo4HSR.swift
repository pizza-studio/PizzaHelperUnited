// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

/// Echo of War weekly attempts(HSR). Unavailable if daily note is fetched from Widget API.
public struct EchoOfWarInfo4HSR: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.weeklyEOWRewardsLeft = try container.decode(Int.self, forKey: .weeklyEOWRewardsLeft)
        self.weeklyEOWMaxRewards = try container.decode(Int.self, forKey: .weeklyEOWMaxRewards)
    }

    // MARK: Public

    public let weeklyEOWRewardsLeft: Int
    public let weeklyEOWMaxRewards: Int

    public var allRewardsClaimed: Bool { weeklyEOWRewardsLeft == 0 }

    public var textDescription: String {
        guard !allRewardsClaimed else { return "✔︎" }
        return "\(weeklyEOWRewardsLeft) / \(weeklyEOWMaxRewards)"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(weeklyEOWRewardsLeft, forKey: .weeklyEOWRewardsLeft)
        try container.encode(weeklyEOWMaxRewards, forKey: .weeklyEOWMaxRewards)
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case weeklyEOWRewardsLeft = "weekly_cocoon_cnt"
        case weeklyEOWMaxRewards = "weekly_cocoon_limit"
    }
}
