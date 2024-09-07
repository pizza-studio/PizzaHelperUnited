// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit

extension Defaults.Keys {
    public static let allowAbyssDataCollection = Key<Bool>(
        "allowAbyssDataCollection",
        default: false,
        suite: .baseSuite
    )
}
