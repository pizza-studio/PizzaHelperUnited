// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZWidgetsKit

// MARK: - PZWidgets

public enum PZWidgets {}

extension PZWidgets {
    static var dateFormatter: DateFormatter {
        PZWidgetsSPM.dateFormatter
    }

    static var intervalFormatter: DateComponentsFormatter {
        PZWidgetsSPM.intervalFormatter
    }

    @MainActor
    public static func attemptToAutoInheritOldAccountsIntoProfiles() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
    }

    public static func getAllProfiles() -> [PZProfileSendable] {
        Defaults[.pzProfiles].values.sorted {
            $0.priority < $1.priority
        }
    }
}
