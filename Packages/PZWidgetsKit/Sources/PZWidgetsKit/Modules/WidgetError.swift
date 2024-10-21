// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

enum WidgetError: CustomLocalizedStringResourceConvertible, LocalizedError {
    case accountSelectNeeded
    case noAccountFound

    // MARK: Internal

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .accountSelectNeeded:
            "widgetError.accountSelectNeeded"
        case .noAccountFound:
            "widgetError.noAccountFound"
        }
    }

    var errorDescription: String? {
        String(localized: localizedStringResource)
    }
}
