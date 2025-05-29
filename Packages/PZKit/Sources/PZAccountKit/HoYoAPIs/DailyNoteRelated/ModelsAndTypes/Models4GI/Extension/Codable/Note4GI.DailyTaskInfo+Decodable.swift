// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - DailyTaskInfo4GI

// MARK: Decodable

extension FullNote4GI.DailyTaskInfo4GI: Decodable {
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
