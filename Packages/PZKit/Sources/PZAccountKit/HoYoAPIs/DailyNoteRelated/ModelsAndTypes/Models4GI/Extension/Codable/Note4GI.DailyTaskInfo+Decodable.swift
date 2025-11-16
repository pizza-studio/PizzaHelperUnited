// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - DailyTaskInfo4GI

// MARK: Decodable

extension FullNote4GI.DailyTaskInfo4GI {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.totalTaskCount = try container.decode(Int.self, forKey: .totalTaskCount)

        let dailyTaskContainer = try container.nestedContainer(keyedBy: DailyTaskCodingKeys.self, forKey: .dailyTask)

        self.finishedTaskCount = try dailyTaskContainer.decode(Int.self, forKey: .finishedNumber)
        self.isExtraRewardReceived = try dailyTaskContainer.decode(Bool.self, forKey: .isExtraRewardReceived)

        var taskRewardsContainer = try dailyTaskContainer.nestedUnkeyedContainer(forKey: .taskRewards)
        var taskRewards = [Bool]()
        while !taskRewardsContainer.isAtEnd {
            let taskRewardContainer = try taskRewardsContainer.nestedContainer(keyedBy: TaskRewardCodingKeys.self)
            taskRewards
                .append(!(try taskRewardContainer.decode(String.self, forKey: .status) == "TaskRewardStatusUnfinished"))
        }
        self.taskRewards = taskRewards

        var attendanceRewardsContainer = try dailyTaskContainer.nestedUnkeyedContainer(forKey: .attendanceRewards)
        var attendanceRewards = [Double]()
        while !attendanceRewardsContainer.isAtEnd {
            let attendanceRewardContainer = try attendanceRewardsContainer
                .nestedContainer(keyedBy: AttendanceRewardCodingKeys.self)
            attendanceRewards.append(Double(try attendanceRewardContainer.decode(Int.self, forKey: .progress)) / 2000.0)
        }
        self.attendanceRewards = attendanceRewards
    }

    private enum CodingKeys: String, CodingKey {
        case totalTaskCount = "total_task_num"
        case dailyTask = "daily_task"
    }

    private enum DailyTaskCodingKeys: String, CodingKey {
        case finishedNumber = "finished_num"
        case attendanceRewards = "attendance_rewards"
        case taskRewards = "task_rewards"
        case isExtraRewardReceived = "is_extra_task_reward_received"
    }

    private enum AttendanceRewardCodingKeys: String, CodingKey {
        case status
        case progress
    }

    private enum TaskRewardCodingKeys: String, CodingKey {
        case status
    }
}

// MARK: Encodable

extension FullNote4GI.DailyTaskInfo4GI {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalTaskCount, forKey: .totalTaskCount)
        var dailyTaskContainer = container.nestedContainer(keyedBy: DailyTaskCodingKeys.self, forKey: .dailyTask)
        try dailyTaskContainer.encode(finishedTaskCount, forKey: .finishedNumber)
        try dailyTaskContainer.encode(isExtraRewardReceived, forKey: .isExtraRewardReceived)

        var taskRewardsContainer = dailyTaskContainer.nestedUnkeyedContainer(forKey: .taskRewards)
        for reward in taskRewards {
            var taskRewardContainer = taskRewardsContainer.nestedContainer(keyedBy: TaskRewardCodingKeys.self)
            try taskRewardContainer.encode(
                reward ? "TaskRewardStatusFinished" : "TaskRewardStatusUnfinished",
                forKey: .status
            )
        }

        var attendanceRewardsContainer = dailyTaskContainer.nestedUnkeyedContainer(forKey: .attendanceRewards)
        for progress in attendanceRewards {
            var attendanceRewardContainer = attendanceRewardsContainer
                .nestedContainer(keyedBy: AttendanceRewardCodingKeys.self)
            try attendanceRewardContainer.encode("SomeStatus", forKey: .status) // 若有 status 字段请替换
            let calculatedProgress = (progress * 2000.0).asIntIfFinite() ?? 0
            try attendanceRewardContainer.encode(calculatedProgress, forKey: .progress)
        }
    }
}
