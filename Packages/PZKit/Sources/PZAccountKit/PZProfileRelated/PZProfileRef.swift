// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - PZProfileRef

/// PZProfileMO 不适合拿来滥用成在外部使用的 Reference Type，所以单独构建一个。
@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
public final class PZProfileRef: Identifiable, PZProfileRefProtocol, ObservableObject {
    // MARK: Lifecycle

    required public init(
        game: Pizza.SupportedGame,
        server: HoYo.Server,
        uid: String,
        uuid: UUID,
        allowNotification: Bool,
        cookie: String,
        deviceFingerPrint: String,
        name: String,
        priority: Int,
        serverRawValue: String,
        sTokenV2: String? = nil,
        deviceID: String
    ) {
        self.game = game
        self.server = server
        self.uid = uid
        self.uuid = uuid
        self.allowNotification = allowNotification
        self.cookie = cookie
        self.deviceFingerPrint = deviceFingerPrint
        self.name = name
        self.priority = priority
        self.serverRawValue = serverRawValue
        self.sTokenV2 = sTokenV2
        self.deviceID = deviceID
    }

    // MARK: Public

    public var uid: String = "114514810"
    public var uuid: UUID = .init()
    public var allowNotification: Bool = true
    public var cookie: String = ""
    public var deviceFingerPrint: String = ""
    public var name: String = ""
    public var priority: Int = 0
    public var serverRawValue: String = HoYo.Server.celestia(.genshinImpact).rawValue
    public var sTokenV2: String? = ""
    public var deviceID: String = UUID().uuidString // For cross-device purposes.

    public var server: HoYo.Server = .celestia(.genshinImpact) {
        didSet {
            serverRawValue = server.rawValue
        }
    }

    public var game: Pizza.SupportedGame = .genshinImpact {
        didSet {
            server.changeGame(to: game)
            serverRawValue = server.rawValue
        }
    }

    public var id: UUID { uuid }
}

// MARK: Hashable, Equatable

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZProfileRef: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        asSendable.hash(into: &hasher)
    }

    public static func == (lhs: PZProfileRef, rhs: PZProfileRef) -> Bool {
        lhs.asSendable == rhs.asSendable
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZProfileRef {
    /// 此处得重复一遍该 Protocol 方法，不然就只能针对 var 变数使用该函式了。
    public func inherit(from target: some ProfileProtocol) {
        uid = target.uid
        uuid = target.uuid
        allowNotification = target.allowNotification
        cookie = target.cookie
        deviceFingerPrint = target.deviceFingerPrint
        name = target.name
        priority = target.priority
        serverRawValue = target.serverRawValue
        sTokenV2 = target.sTokenV2
        deviceID = target.deviceID
        game = target.game
        server = target.server
    }
}
