// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

extension String {
    public var i18nWatch: String {
        String(localized: .init(stringLiteral: self), bundle: .currentSPM)
    }
}

extension String.LocalizationValue {
    public var i18nWatch: String {
        String(localized: self, bundle: .currentSPM)
    }
}
