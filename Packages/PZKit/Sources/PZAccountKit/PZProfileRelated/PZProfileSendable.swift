// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - PZProfileSendable

/// 这个结构仅用于任何需要跨任务传送 PZProfileMO 资料的场合。
@frozen
public struct PZProfileSendable: Sendable {
    public let game: Pizza.SupportedGame
    public let server: HoYo.Server
    public let uid: String
    public let uuid: UUID
    public let allowNotification: Bool
    public let cookie: String
    public let deviceFingerPrint: String
    public let name: String
    public let priority: Int
    public let serverRawValue: String
    public let sTokenV2: String?
    public let deviceID: String
}

extension PZProfileMO {
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

extension PZProfileSendable {
    public var asMO: PZProfileMO {
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
