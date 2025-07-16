// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts
import PZProfileCDMOBackports

// MARK: - PZProfileSendable

/// 这个结构仅用于任何需要跨任务传送 PZProfileMO 资料的场合。
@frozen
public struct PZProfileSendable: AbleToCodeSendHash, Equatable, Identifiable, ProfileProtocol {
    public var game: Pizza.SupportedGame
    public var server: HoYo.Server
    public var uid: String
    public var uuid: UUID
    public var allowNotification: Bool
    public var cookie: String
    public var deviceFingerPrint: String
    public var name: String
    public var priority: Int
    public var serverRawValue: String
    public var sTokenV2: String?
    public var deviceID: String

    public var id: UUID { uuid }
}

extension PZProfileSendable {
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
        var result = getDummyInstance(for: game)
        result.deviceID = ThisDevice.identifier4Vendor.description

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

    /// 专门用来从旧版 AccountMO 迁移到全新的 PZProfileMO 账号体系的建构子。
    /// 不过，为了在某些 Concurrency 环境下使用方便，这个建构子并不分配当前设备唯一的 DeviceID。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: UID。
    ///   - configuration: 旧版 AccountMO。
    public static func makeInheritedInstanceWithRandomDeviceID(
        game: Pizza.SupportedGame, uid: String,
        configuration: AccountMOProtocol? = nil
    )
        -> Self? {
        guard let server = HoYo.Server(uid: uid, game: game) else { return nil }
        // .description 很重要，防止 EXC_BAD_ACCESS。
        var result = getDummyInstance(for: game)
        result.deviceID = UUID().uuidString

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

extension PZProfileSendable {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}

extension Array where Element == PZProfileSendable {
    public var hasPriorityIssues: Bool {
        priorityIssuesSolvedForm != nil
    }

    /// This property returns nil if no problem to solve.
    public var priorityIssuesSolvedForm: Self? {
        let oldHash = hashValue
        var newProfiles = self
        newProfiles.fixPrioritySettings()
        return oldHash != newProfiles.hashValue ? newProfiles : nil
    }
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZProfileSendable {
    internal var asMO: PZProfileMO {
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
    public var asRef: PZProfileRef {
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
    public var asCDMO: PZProfileCDMO {
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
