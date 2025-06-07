// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - DailyTrainingInfo4HSR

public struct DailyTrainingInfo4HSR: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentScore = try container.decode(Int.self, forKey: .currentScore)
        self.maxScore = try container.decode(Int.self, forKey: .maxScore)
    }

    // MARK: Public

    public let currentScore: Int
    public let maxScore: Int

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case currentScore = "current_train_score"
        case maxScore = "max_train_score"
    }
}
