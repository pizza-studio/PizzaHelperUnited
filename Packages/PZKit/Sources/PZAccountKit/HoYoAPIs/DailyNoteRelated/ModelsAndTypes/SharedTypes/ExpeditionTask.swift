// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - ExpeditionTask

public protocol ExpeditionTask: AbleToCodeSendHash {
    var isFinished: Bool { get }
    var iconURL: URL { get }
    var iconURL4Copilot: URL? { get } // 星穹铁道的探索派遣允许设定第二个角色，所以就有了这个栏位。
    var game: Pizza.SupportedGame { get }
    static var game: Pizza.SupportedGame { get }
}

extension ExpeditionTask {
    // Expedition Protocol Method.
    public var game: Pizza.SupportedGame { Self.game }
    // Expedition Protocol Method.
    public var timeOnFinish: Date? {
        // 星穹铁道官方 API 移除了对探索派遣的资料提供，故彻底移除相关代码。
        switch self {
        case let data as FullNote4GI.ExpeditionInfo4GI.Expedition: return data.finishTime
        case _ as WidgetNote4GI.ExpeditionInfo4GI.Expedition: return nil
        default: return nil
        }
    }

    public var timeRemainingText: String? {
        guard let finishTime = timeOnFinish else { return nil }
        guard !isFinished else { return nil }
        let rawRemaining = TimeInterval.sinceNow(to: finishTime)
        let timeRemaining = DailyNoteSafeMath.nonNegativeInterval(rawRemaining)
        return HoYo.formattedInterval(for: timeRemaining)
    }

    public var percOfCompletion: Double? {
        guard let finishTime = timeOnFinish else { return nil }
        guard !isFinished else { return 1 }
        let totalSecond = 20.0 * 60.0 * 60.0
        let rawRemaining = TimeInterval.sinceNow(to: finishTime)
        let timeRemaining = DailyNoteSafeMath.nonNegativeInterval(rawRemaining)
        let cappedRemaining = Swift.min(timeRemaining, totalSecond)
        let percentage = (totalSecond - cappedRemaining) > 0
            ? (totalSecond - cappedRemaining) / totalSecond
            : 0.0
        return DailyNoteSafeMath.clamp(percentage, to: 0 ... 1)
    }
}

extension [ExpeditionTask] {
    public var hasPendingTask: Bool {
        !self.map { !$0.isFinished }.isEmpty
    }

    public var pendingTaskCount: Int {
        self.filter { !$0.isFinished }.count
    }

    public var finishedTaskCount: Int {
        self.filter(\.isFinished).count
    }

    public var allAccomplished: Bool {
        !hasPendingTask
    }

    public var totalETA: Date? {
        compactMap(\.timeOnFinish).max()
    }
}
