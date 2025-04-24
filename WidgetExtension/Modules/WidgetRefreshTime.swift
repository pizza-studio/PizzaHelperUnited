// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

public var widgetRefreshByMinute: Int {
    Int(Defaults[.allWidgetsSyncFrequencyByMinutes].rounded(.down))
}

extension PZWidgets {
    private static let refreshWhenSucceedAfterHour: Double = 2.0
    private static let refreshWhenErrorMinute: Double = 15

    private static var refreshWhenSucceedAfterSecond: Double { refreshWhenSucceedAfterHour * 60 * 60 }
    private static var refreshWhenErrorAfterSecond: Double { refreshWhenErrorMinute * 60 }

    public static func getRefreshDate(isError: Bool = false) -> Date {
        Date(timeIntervalSinceNow: isError ? PZWidgets.refreshWhenErrorAfterSecond : refreshWhenSucceedAfterSecond)
    }

    public static func getRefreshDateByGameStamina(game: Pizza.SupportedGame? = nil) -> Date {
        Date(timeIntervalSinceNow: game?.eachStaminaRecoveryTime ?? 60)
    }

    public static func getSharedRefreshDateFor(game1: Pizza.SupportedGame, game2: Pizza.SupportedGame) -> Date {
        let a = Int(game1.eachStaminaRecoveryTime)
        let b = Int(game2.eachStaminaRecoveryTime)
        let gcd = greatestCommonDivisor(a, b)
        return Date(timeIntervalSinceNow: Double(gcd))
    }
}

private func greatestCommonDivisor(_ a: Int, _ b: Int) -> Int {
    let r = a % b
    if r != 0 {
        return greatestCommonDivisor(b, r)
    } else {
        return b
    }
}
