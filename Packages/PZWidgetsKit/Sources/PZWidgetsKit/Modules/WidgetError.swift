// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

enum WidgetError: CustomLocalizedStringResourceConvertible, LocalizedError {
    case accountSelectionNeeded
    case noAccountFound

    // MARK: Internal

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .accountSelectionNeeded:
            /// "请长按进入小组件重新设置账号信息"
            "widgetError.accountSelectionNeeded"
        case .noAccountFound:
            /// "请进入App设置账号信息"
            "widgetError.noAccountFound"
        }
    }

    var description: String {
        String(localized: localizedStringResource)
    }

    var errorDescription: String? {
        String(localized: localizedStringResource)
    }
}
