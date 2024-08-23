// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - WidgetNote4GI

public struct WidgetNote4GI: Note4GI {
    public struct DailyTaskInfo4GI: PZAccountKit.DailyTaskInfo4GI {
        public let totalTaskCount: Int
        public let finishedTaskCount: Int
        public let isExtraRewardReceived: Bool
    }

    public struct ExpeditionInfo4GI: PZAccountKit.ExpeditionInfo4GI {
        public struct Expedition: PZAccountKit.Expedition {
            public let isFinished: Bool
            public let iconURL: URL
        }

        public let maxExpeditionsCount: Int
        public let expeditions: [Expedition]
    }

    public struct HomeCoinInfo4GI: PZAccountKit.HomeCoinInfo4GI {
        public let maxHomeCoin: Int
        public let currentHomeCoin: Int

        public let fullTime: Date
    }

    public struct ResinInfo4GI: PZAccountKit.ResinInfo4GI {
        public let maxResin: Int
        public let currentResin: Int
        public let resinRecoveryTime: Date
    }

    public let dailyTaskInfo: DailyTaskInfo4GI
    public let expeditionInfo4GI: ExpeditionInfo4GI
    public let homeCoinInfo: HomeCoinInfo4GI
    public let resinInfo: ResinInfo4GI
}

extension WidgetNote4GI {
    func exampleData() -> WidgetNote4GI {
        let exampleURL = Bundle.module.url(forResource: "gi_widget_note_example", withExtension: "json")!
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! WidgetNote4GI.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
