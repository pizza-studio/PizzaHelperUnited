// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZWidgetsKit

// MARK: - PZWidgets

public enum PZWidgets {}

extension PZWidgets {
    public static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
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

    public static func getAllProfiles() -> [PZProfileSendable] {
        Defaults[.pzProfiles].values.sorted {
            $0.priority < $1.priority
        }
    }
}
