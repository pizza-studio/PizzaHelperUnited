// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - PZGachaEntryProtocol

public protocol PZGachaEntryProtocol {
    var game: String { get set }
    var uid: String { get set }
    var gachaType: String { get set }
    var itemID: String { get set }
    var count: String { get set }
    var time: String { get set }
    var name: String { get set }
    var lang: String { get set }
    var itemType: String { get set }
    var rankType: String { get set }
    var id: String { get set }
    var gachaID: String { get set }
}

extension PZGachaEntryProtocol {
    public var gameTyped: Pizza.SupportedGame {
        .init(rawValue: game) ?? .genshinImpact
    }

    public var uidWithGame: String {
        "\(gameTyped.uidPrefix)-\(uid)"
    }

    public static func makeEntryID() -> String {
        var stringStack = "9"
        while stringStack.count < 19 {
            stringStack.append(Int.random(in: 0 ... 9).description)
        }
        return stringStack
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZGachaEntryProtocol {
    public var expressible: GachaEntryExpressible {
        .init(rawEntry: self)
    }
}
