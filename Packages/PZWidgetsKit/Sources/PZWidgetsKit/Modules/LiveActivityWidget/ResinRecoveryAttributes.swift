// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
#if canImport(ActivityKit)
import ActivityKit

struct ResinRecoveryAttributes: ActivityAttributes {
    // MARK: Public

    public typealias ResinRecoveryState = ContentState

    public struct ContentState: Codable, Hashable {
        // MARK: Lifecycle

        init(
            resinInfo: ResinInformation,
            expeditionInfo: some ExpeditionInformation,
            showExpedition: Bool,
            background: ResinRecoveryActivityBackground
        ) {
            self.resinCountWhenUpdated = resinInfo.currentResin
            self.resinRecoveryTime = resinInfo.resinRecoveryTime
            if let expeditionInfo = expeditionInfo as? GeneralNote4GI.ExpeditionInfo4GI {
                self.expeditionAllCompleteTime = expeditionInfo.expeditions.map(\.finishTime).max()
            } else {
                self.expeditionAllCompleteTime = nil
            }
            self.showExpedition = showExpedition
            self.background = background
        }

        // MARK: Internal

        let resinCountWhenUpdated: Int
        let resinRecoveryTime: Date
        let expeditionAllCompleteTime: Date?
        let showExpedition: Bool

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
            currentResin = ResinInfo.defaultMaxResin
        } else {
            currentResin = ResinInfo.defaultMaxResin - Int(ceil(minuteRemaining / 8))
        }
        return currentResin
    }

    /// 下一20倍数树脂
    var next20ResinCount: Int {
        Int(ceil((Double(currentResin) + 0.01) / 20.0)) * 20
    }

    var showNext20Resin: Bool {
        next20ResinCount != ResinInfo.defaultMaxResin
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
