// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
extension ResinInfo4GI {
    public var currentResinDynamic: Int {
        calculatedCurrentResin(referTo: .init())
    }

    public func calculatedCurrentResin(referTo date: Date) -> Int {
        let secondToFull = resinRecoveryTime.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
        guard secondToFull > 0 else { return maxResin }
        return maxResin - Int(ceil(secondToFull / 8 / 60))
    }
}
