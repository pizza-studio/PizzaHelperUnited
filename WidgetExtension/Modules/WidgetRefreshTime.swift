// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

extension PZWidgets {
    public static func getWidgetsSyncFrequency(game: Pizza.SupportedGame) -> Int {
        let staminaPoints = Swift.max(Swift.abs(Defaults[.allWidgetsSyncFrequencyByStaminaPoints]), 1)
        return staminaPoints * Int(game.eachStaminaRecoveryTime)
    }
}
