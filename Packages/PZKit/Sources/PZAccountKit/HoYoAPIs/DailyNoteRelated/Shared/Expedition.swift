// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Expedition

public protocol Expedition {
    var isFinished: Bool { get }
    var iconURL: URL { get }
    var game: Pizza.SupportedGame { get }
    static var game: Pizza.SupportedGame { get }
}

extension Expedition {
    public var game: Pizza.SupportedGame { Self.game }
}
