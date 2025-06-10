// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - PZProfileSendable

/// 这个结构仅用于任何需要跨任务传送 PZProfileMO 资料的场合。
@frozen
public struct PZProfileSendable: AbleToCodeSendHash, Equatable, Identifiable, ProfileProtocol {
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

    public var id: UUID { uuid }
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

    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}

extension PZProfileSendable {
    public static func getDummyInstance(for game: Pizza.SupportedGame) -> Self {
        switch game {
        case .genshinImpact:
            .init(
                game: .genshinImpact,
                server: .celestia(.genshinImpact),
                uid: "100000000",
                uuid: .init(),
                allowNotification: false,
                cookie: "",
                deviceFingerPrint: "",
                name: "Hotaru",
                priority: 0,
                serverRawValue: "cn_gf01",
                sTokenV2: nil,
                deviceID: ""
            )
        case .starRail:
            .init(
                game: .starRail,
                server: .celestia(.starRail),
                uid: "100000000",
                uuid: .init(),
                allowNotification: false,
                cookie: "",
                deviceFingerPrint: "",
                name: "Stelle",
                priority: 0,
                serverRawValue: "prod_gf_cn",
                sTokenV2: nil,
                deviceID: ""
            )
        case .zenlessZone:
            .init(
                game: .zenlessZone,
                server: .celestia(.zenlessZone),
                uid: "10000000",
                uuid: .init(),
                allowNotification: false,
                cookie: "",
                deviceFingerPrint: "",
                name: "Belle",
                priority: 0,
                serverRawValue: "prod_gf_cn",
                sTokenV2: nil,
                deviceID: ""
            )
        }
    }
}
