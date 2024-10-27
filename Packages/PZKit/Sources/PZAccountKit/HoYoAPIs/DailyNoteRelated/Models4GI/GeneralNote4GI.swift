// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - GeneralNote4GI

public struct GeneralNote4GI: Note4GI {
    public struct DailyTaskInfo4GI: PZAccountKit.DailyTaskInfo4GI, Sendable {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool

        /// 历练点进度百分比
        public let attendanceRewards: [Double]

        /// 每个每日任务状态
        public let taskRewards: [Bool]

        // MARK: Private
    }

    public struct ExpeditionInfo4GI: PZAccountKit.ExpeditionInfo4GI, Sendable {
        public struct Expedition: PZAccountKit.Expedition, Sendable {
            public static let game: Pizza.SupportedGame = .genshinImpact

            public let finishTime: Date
            public let iconURL: URL

            public var isFinished: Bool { finishTime <= Date() }
        }

        public let maxExpeditionsCount: Int
        public let expeditions: [Expedition]
    }

    public struct HomeCoinInfo4GI: PZAccountKit.HomeCoinInfo4GI, Sendable {
        public let maxHomeCoin: Int
        public let currentHomeCoin: Int
        public let fullTime: Date
    }

    public struct ResinInfo4GI: PZAccountKit.ResinInfo4GI, Sendable {
        public let maxResin: Int
        public let currentResin: Int
        public let resinRecoveryTime: Date
    }

    public struct TransformerInfo4GI: Sendable {
        public let obtained: Bool
        public let recoveryTime: Date
    }

    public struct WeeklyBossesInfo4GI: Sendable {
        public let totalResinDiscount: Int
        public let remainResinDiscount: Int
    }

    public let dailyTaskInfo: DailyTaskInfo4GI
    public let resinInfo: ResinInfo4GI
    public let weeklyBossesInfo: WeeklyBossesInfo4GI
    public let expeditions: ExpeditionInfo4GI
    public let transformerInfo: TransformerInfo4GI
    public let homeCoinInfo: HomeCoinInfo4GI
}

extension GeneralNote4GI {
    public static func exampleData() -> GeneralNote4GI {
        let exampleURL = Bundle.module.url(forResource: "gi_general_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! GeneralNote4GI.decodeFromMiHoYoAPIJSONResult(
            data: exampleData,
            debugTag: "GeneralNote4GI.exampleData()"
        )
    }
}
