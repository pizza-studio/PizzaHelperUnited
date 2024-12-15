// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

extension WidgetNote4GI.DailyTaskInfo4GI: Decodable {
    enum CodingKeys: String, CodingKey {
        case totalTaskCount = "total_task_num"
        case finishedTaskCount = "finished_task_num"
        case isExtraRewardReceived = "is_extra_task_reward_received"
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<WidgetNote4GI.DailyTaskInfo4GI.CodingKeys> = try decoder
            .container(keyedBy: WidgetNote4GI.DailyTaskInfo4GI.CodingKeys.self)
        self.totalTaskCount = try container.decode(
            Int.self,
            forKey: WidgetNote4GI.DailyTaskInfo4GI.CodingKeys.totalTaskCount
        )
        self.finishedTaskCount = try container.decode(
            Int.self,
            forKey: WidgetNote4GI.DailyTaskInfo4GI.CodingKeys.finishedTaskCount
        )
        self.isExtraRewardReceived = try container.decode(
            Bool.self,
            forKey: WidgetNote4GI.DailyTaskInfo4GI.CodingKeys.isExtraRewardReceived
        )
    }
}
