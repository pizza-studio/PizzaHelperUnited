// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - WidgetNote4GI + Decodable

extension WidgetNote4GI: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.dailyTaskInfo = try container.decode(WidgetNote4GI.DailyTaskInfo4GI.self)
        self.expeditionInfo = try container.decode(WidgetNote4GI.ExpeditionInfo4GI.self)
        self.homeCoinInfo = try container.decode(WidgetNote4GI.HomeCoinInfo4GI.self)
        self.resinInfo = try container.decode(WidgetNote4GI.ResinInfo4GI.self)
    }
}

// MARK: - WidgetNote4GI + Encodable

extension WidgetNote4GI: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dailyTaskInfo)
        try container.encode(expeditionInfo)
        try container.encode(homeCoinInfo)
        try container.encode(resinInfo)
    }
}

// MARK: - WidgetNote4GI + DecodableFromMiHoYoAPIJSONResult

extension WidgetNote4GI: DecodableFromMiHoYoAPIJSONResult {}
