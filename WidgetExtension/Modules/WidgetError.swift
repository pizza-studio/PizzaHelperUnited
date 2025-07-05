// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
enum WidgetError: CustomLocalizedStringResourceConvertible, LocalizedError {
    case profileSelectionNeeded
    case noProfileFound

    // MARK: Internal

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .profileSelectionNeeded:
            /// "请长按进入小组件重新设置账号资讯"
            "pzWidgetsKit.widgetError.profileSelectionNeeded"
        case .noProfileFound:
            /// "请进入App设置账号资讯"
            "pzWidgetsKit.widgetError.noProfileFound"
        }
    }

    var description: String {
        String(localized: localizedStringResource)
    }

    var errorDescription: String? {
        String(localized: localizedStringResource)
    }
}
