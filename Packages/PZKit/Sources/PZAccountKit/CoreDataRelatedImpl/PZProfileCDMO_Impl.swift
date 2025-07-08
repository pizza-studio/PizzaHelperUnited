// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKitShared
import PZProfileCDMOBackports
import SwiftData

// MARK: - PZProfileCDMO + ProfileProtocol

extension PZProfileCDMO: ProfileProtocol {
    public var game: Pizza.SupportedGame {
        get {
            let matchedRaw = try? SDStringEnumCodec.decodeRawValue(
                from: gameBlob, fieldName: "game"
            )
            guard let matchedRaw else { return .genshinImpact }
            return Pizza.SupportedGame(rawValue: matchedRaw) ?? .genshinImpact
        }
        set {
            do {
                gameBlob = try SDStringEnumCodec.encodeRawValue(newValue.rawValue, forKey: "game")
            } catch {
                // Do not handle. This shouldn't happen.
                return
            }
        }
    }

    public var server: HoYo.Server {
        get {
            let matchedRaw = try? SDStringEnumCodec.decodeRawValue(
                from: serverBlob, fieldName: "server"
            )
            guard let matchedRaw else { return .celestia(game) }
            return .init(rawValue: matchedRaw)?.withGame(game) ?? .celestia(game)
        }
        set {
            do {
                serverBlob = try SDStringEnumCodec.encodeRawValue(newValue.rawValue, forKey: "server")
            } catch {
                // Do not handle. This shouldn't happen.
                return
            }
        }
    }
}

extension PZProfileCDMO {
    public init(
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
        self.init()
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
        self.game = game
        self.server = server
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
