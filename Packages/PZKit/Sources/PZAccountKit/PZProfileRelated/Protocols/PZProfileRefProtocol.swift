// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts

// MARK: - PZProfileRefProtocol

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
}

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
