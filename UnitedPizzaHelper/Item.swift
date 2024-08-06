// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftData

@Model
final class Item {
    // MARK: Lifecycle

    init(timestamp: Date) {
        self.timestamp = timestamp
    }

    // MARK: Internal

    var timestamp: Date
}
