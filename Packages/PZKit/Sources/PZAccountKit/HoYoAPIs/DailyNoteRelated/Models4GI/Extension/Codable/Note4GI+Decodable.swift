// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - GeneralNote4GI + Decodable

extension GeneralNote4GI: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dailyTaskInfo = try container.decode(DailyTaskInfo4GI.self)
        self.resinInfo = try container.decode(ResinInfo4GI.self)
        self.weeklyBossesInfo = try container.decode(WeeklyBossesInfo4GI.self)
        self.expeditionInfo4GI = try container.decode(ExpeditionInfo4GI.self)
        self.transformerInfo = try container.decode(TransformerInfo4GI.self)
        self.homeCoinInfo = try container.decode(HomeCoinInfo4GI.self)
    }
}

// MARK: - GeneralNote4GI + DecodableFromMiHoYoAPIJSONResult

extension GeneralNote4GI: DecodableFromMiHoYoAPIJSONResult {}
