// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension String {
    public var i18nGachaKit: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

extension String.LocalizationValue {
    public var i18nGachaKit: String {
        String(localized: self, bundle: .module)
    }
}

extension StringProtocol {
    public var isInt: Bool {
        Int(self) != nil
    }

    public var isNotInt: Bool {
        Int(self) == nil
    }
}
