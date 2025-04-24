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
}
