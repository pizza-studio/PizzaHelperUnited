// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

@available(iOS 16.2, macCatalyst 16.2, *)
extension String {
    public var i18nPZWidgetsKit: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension String.LocalizationValue {
    public var i18nPZWidgetsKit: String {
        String(localized: self, bundle: .module)
    }
}
