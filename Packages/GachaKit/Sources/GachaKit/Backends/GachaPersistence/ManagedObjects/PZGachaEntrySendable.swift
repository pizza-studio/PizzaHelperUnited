// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - PZGachaEntrySendable

/// 这个 Struct 就做一件事情：跨 Actor 传输资料。
@frozen
@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct PZGachaEntrySendable: PZGachaEntryProtocol, AbleToCodeSendHash, Identifiable {
    // MARK: Lifecycle

    public init(handler: ((inout PZGachaEntrySendable) -> Void)? = nil) {
        handler?(&self)
    }

    // MARK: Public

    public var game: String = "GI"
    public var uid: String = "000000000"
    public var gachaType: String = "5"
    public var itemID: String = UUID().uuidString
    public var count: String = "1"
    public var time: String = "2000-01-01 00:00:00"
    public var name: String = "YJSNPI"
    public var lang: String = "zh-cn"
    public var itemType: String = "武器"
    public var rankType: String = "3"
    public var id: String = PZGachaEntryMO.makeEntryID()
    public var gachaID: String = "0"

    public var asMO: PZGachaEntryMO {
        .init { this in
            this.game = game
            this.uid = uid
            this.gachaType = gachaType
            this.itemID = itemID
            this.count = count
            this.time = time
            this.name = name
            this.lang = lang
            this.itemType = itemType
            this.rankType = rankType
            this.id = id
            this.gachaID = gachaID
        }
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension PZGachaEntryMO {
    public var asSendable: PZGachaEntrySendable {
        .init { this in
            this.game = self.game
            this.uid = self.uid
            this.gachaType = self.gachaType
            this.itemID = self.itemID
            this.count = self.count
            this.time = self.time
            this.name = self.name
            this.lang = self.lang
            this.itemType = self.itemType
            this.rankType = self.rankType
            this.id = self.id
            this.gachaID = self.gachaID
        }
    }
}
