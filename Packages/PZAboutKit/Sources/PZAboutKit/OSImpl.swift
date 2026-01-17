// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

@available(iOS 15.0, macCatalyst 15.0, *)
extension String {
    public var i18nAboutKit: String {
        String(localized: .init(stringLiteral: self), bundle: .currentSPM)
    }
}

@available(iOS 15.0, macCatalyst 15.0, *)
extension String.LocalizationValue {
    public var i18nAboutKit: String {
        String(localized: self, bundle: .currentSPM)
    }
}
