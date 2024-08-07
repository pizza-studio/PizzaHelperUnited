// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - EnkaDBProtocol

public protocol EnkaDBProtocol {
    var game: Enka.HoyoGame { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }
}

extension EnkaDBProtocol {}
