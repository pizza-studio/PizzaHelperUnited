// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension String {
    public var i18nRefugee: String {
        NSLocalizedString(
            self,
            bundle: .module,
            comment: ""
        )
    }
}
