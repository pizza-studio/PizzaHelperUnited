// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts

// MARK: - PZProfileRefProtocol

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public protocol PZProfileRefProtocol: AnyObject, ProfileMOProtocol, Codable {
    init(
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
        sTokenV2: String?,
        deviceID: String
    )

    var asSendable: PZProfileSendable { get }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileRefProtocol {
    @MainActor
    public static func new(server: HoYo.Server, uid: String) -> Self {
        // .description 很重要，防止 EXC_BAD_ACCESS。
        Self.makeDefaultInstance(server: server, uid: uid)
    }

    @MainActor
    public static func makeNewInstance(
        server: HoYo.Server,
        uid: String
    )
        -> Self {
        makeDefaultInstance(server: server, uid: uid)
    }

    @MainActor
    public static func makeDefaultInstance(
        game: Pizza.SupportedGame = Pizza.SupportedGame.genshinImpact,
        server: HoYo.Server = HoYo.Server.celestia(.genshinImpact),
        uid: String = "114514810",
        uuid: UUID = UUID(),
        allowNotification: Bool = true,
        cookie: String = "",
        deviceFingerPrint: String = "",
        name: String = "",
        priority: Int = 0,
        serverRawValue: String = HoYo.Server.celestia(.genshinImpact).rawValue,
        sTokenV2: String? = "",
        deviceID: String? = nil,
    )
        -> Self {
        .init(
            game: game,
            server: server,
            uid: uid,
            uuid: uuid,
            allowNotification: allowNotification,
            cookie: cookie,
            deviceFingerPrint: deviceFingerPrint,
            name: name,
            priority: priority,
            serverRawValue: serverRawValue,
            sTokenV2: sTokenV2,
            deviceID: deviceID ?? ThisDevice.identifier4Vendor.description
        )
    }

    // MARK: Lifecycle

    /// 专门用来从旧版 AccountMO 迁移到全新的 PZProfileMO 账号体系的建构子。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: UID。
    ///   - configuration: 旧版 AccountMO。
    @MainActor
    public static func makeInheritedInstance(
        game: Pizza.SupportedGame, uid: String,
        configuration: AccountMOProtocol? = nil
    )
        -> Self? {
        guard let server = HoYo.Server(uid: uid, game: game) else { return nil }
        // .description 很重要，防止 EXC_BAD_ACCESS。
        var result = makeDefaultInstance()
        result.game = game
        result.uid = uid
        result.serverRawValue = server.rawValue
        result.server = server.withGame(game)
        if let configuration {
            result.allowNotification = configuration.allowNotification
            result.cookie = configuration.cookie
            result.deviceFingerPrint = configuration.deviceFingerPrint
            result.name = configuration.name
            result.priority = configuration.priority
            result.sTokenV2 = configuration.sTokenV2
            result.uid = configuration.uid
            result.uuid = configuration.uuid
        }
        return result
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileRefProtocol {
    public init(from decoder: any Decoder) throws {
        let decoded = try PZProfileSendable(from: decoder)
        self.init(
            game: decoded.game,
            server: decoded.server,
            uid: decoded.uid,
            uuid: decoded.uuid,
            allowNotification: decoded.allowNotification,
            cookie: decoded.cookie,
            deviceFingerPrint: decoded.deviceFingerPrint,
            name: decoded.name,
            priority: decoded.priority,
            serverRawValue: decoded.serverRawValue,
            sTokenV2: decoded.sTokenV2,
            deviceID: decoded.deviceID
        )
    }

    public func encode(to encoder: any Encoder) throws {
        try asSendable.encode(to: encoder)
    }

    public var asSendable: PZProfileSendable {
        .init(
            game: game,
            server: server,
            uid: uid,
            uuid: uuid,
            allowNotification: allowNotification,
            cookie: cookie,
            deviceFingerPrint: deviceFingerPrint,
            name: name,
            priority: priority,
            serverRawValue: serverRawValue,
            sTokenV2: sTokenV2,
            deviceID: deviceID
        )
    }
}

// MARK: - PZProfileRef

/// PZProfileMO 不适合拿来滥用成在外部使用的 Reference Type，所以单独构建一个。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZProfileRef: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        asSendable.hash(into: &hasher)
    }

    public static func == (lhs: PZProfileRef, rhs: PZProfileRef) -> Bool {
        lhs.asSendable == rhs.asSendable
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
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
