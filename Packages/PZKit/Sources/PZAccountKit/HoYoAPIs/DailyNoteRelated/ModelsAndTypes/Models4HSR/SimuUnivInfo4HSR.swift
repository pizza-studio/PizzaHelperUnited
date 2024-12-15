// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - SimuUnivInfo4HSR

public struct SimuUnivInfo4HSR: Sendable {
    public let currentScore: Int
    public let maxScore: Int
}

// MARK: Decodable

extension SimuUnivInfo4HSR: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentScore = try container.decode(Int.self, forKey: .currentScore)
        self.maxScore = try container.decode(Int.self, forKey: .maxScore)
    }

    enum CodingKeys: String, CodingKey {
        case currentScore = "current_rogue_score"
        case maxScore = "max_rogue_score"
    }
}
