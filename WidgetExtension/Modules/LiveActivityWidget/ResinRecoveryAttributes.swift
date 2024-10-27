// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
#if canImport(ActivityKit)
import ActivityKit

struct ResinRecoveryAttributes: ActivityAttributes, Sendable {
    // MARK: Public

    public typealias ResinRecoveryState = ContentState

    public struct ContentState: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        init(
            dailyNote: any DailyNoteProtocol,
            showExpedition: Bool,
            background: ResinRecoveryActivityBackground
        ) {
            self.background = background
            let staminaIntel = dailyNote.staminaIntel
            self.maxResin = staminaIntel.max
            self.resinCountWhenUpdated = staminaIntel.existing
            self.resinRecoveryTime = dailyNote.staminaFullTimeOnFinish
            switch dailyNote {
            case _ as WidgetNote4GI:
                self.game = .genshinImpact
                self.expeditionAllCompleteTime = nil
                self.showExpedition = showExpedition
            case let data as GeneralNote4GI:
                self.game = .genshinImpact
                self.expeditionAllCompleteTime = data.expeditions.expeditions.map(\.finishTime).max() ?? .now
                self.showExpedition = showExpedition
            case let data as Note4HSR:
                self.game = .starRail
                self.expeditionAllCompleteTime = data.assignmentInfo.assignments.map(\.finishedTime).max() ?? .now
                self.showExpedition = showExpedition
            case _ as Note4ZZZ:
                self.game = .zenlessZone
                self.showExpedition = false
                self.expeditionAllCompleteTime = nil
            default:
                self.game = .genshinImpact // 乱填。
                self.showExpedition = false
                self.expeditionAllCompleteTime = nil
            }
        }

        // MARK: Internal

        let game: Pizza.SupportedGame
        let resinCountWhenUpdated: Int
        let resinRecoveryTime: Date
        let expeditionAllCompleteTime: Date?
        let showExpedition: Bool
        let maxResin: Int

        let background: ResinRecoveryActivityBackground
    }

    // MARK: Internal

    let accountName: String
    let accountUUID: UUID
}

extension ResinRecoveryAttributes.ResinRecoveryState {
    var currentResin: Int {
        let secondRemaining = resinRecoveryTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let minuteRemaining = Double(secondRemaining) / 60
        let currentResin: Int
        if minuteRemaining <= 0 {
            currentResin = maxResin
        } else {
            currentResin = maxResin - Int(ceil(minuteRemaining / 8))
        }
        return currentResin
    }

    /// 下一20倍数树脂
    var next20ResinCount: Int {
        Int(ceil((Double(currentResin) + 0.01) / 20.0)) * 20
    }

    var showNext20Resin: Bool {
        next20ResinCount != maxResin
    }

    /// 下一20倍数树脂回复时间点
    var next20ResinRecoveryTime: Date {
        Date(timeIntervalSinceNow: TimeInterval((next20ResinCount - currentResin) * 8 * 60))
    }
}

enum ResinRecoveryActivityBackground: Codable, Equatable, Hashable {
    case random
    case customize([String])
    case noBackground
}
#endif
