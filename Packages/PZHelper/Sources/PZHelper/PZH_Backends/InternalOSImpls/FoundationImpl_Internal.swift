// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension String {
    public var i18nPZHelper: String {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            String(localized: .init(stringLiteral: self), bundle: .module)
        } else {
            NSLocalizedString(self, bundle: .module, comment: "")
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension String.LocalizationValue {
    public var i18nPZHelper: String {
        String(localized: self, bundle: .module)
    }
}
