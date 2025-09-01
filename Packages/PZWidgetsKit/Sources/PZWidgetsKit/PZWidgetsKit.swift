// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - PZWidgetsSPM

@available(iOS 16.2, macCatalyst 16.2, *)
public enum PZWidgetsSPM {}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZWidgetsSPM {
    public static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter.CurrentLocale()
        fmt.doesRelativeDateFormatting = true
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    public static let intervalFormatter: DateComponentsFormatter = {
        let dateComponentFormatter = DateComponentsFormatter()
        dateComponentFormatter.allowedUnits = [.hour, .minute]
        dateComponentFormatter.maximumUnitCount = 2
        dateComponentFormatter.unitsStyle = .brief
        return dateComponentFormatter
    }()
}
