// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

extension FullNote4GI.WeeklyBossesInfo4GI {
    private enum CodingKeys: String, CodingKey {
        case totalResinDiscount = "resin_discount_num_limit"
        case remainResinDiscount = "remain_resin_discount_num"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalResinDiscount = try container.decode(Int.self, forKey: .totalResinDiscount)
        self.remainResinDiscount = try container.decode(Int.self, forKey: .remainResinDiscount)
    }
}

extension FullNote4GI.WeeklyBossesInfo4GI {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalResinDiscount, forKey: .totalResinDiscount)
        try container.encode(remainResinDiscount, forKey: .remainResinDiscount)
    }
}
