// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts

// MARK: - ProfileBasicProtocol

/// AccountMO 不是统一披萨助手引擎用来主要处理的格式，
/// 而是专门为了从 CloudKit 读取既有资料而实作的资料交换格式。
/// 这也是为了方便直接继承旧版原披助手与穹披助手的云端资料。
/// AccountMO 不曝露给前端使用，不直接用于 SwiftUI。
public protocol ProfileBasicProtocol: Codable {
    var allowNotification: Bool { get set }
    var cookie: String { get set }
    var deviceFingerPrint: String { get set }
    var name: String { get set }
    var priority: Int { get set }
    var serverRawValue: String { get set }
    var sTokenV2: String? { get set }
    var uid: String { get set }
    var uuid: UUID { get set }
}

extension Array where Element: ProfileBasicProtocol {
    mutating public func fixPrioritySettings(respectExistingPriority: Bool = false) {
        var newResult = self
        if respectExistingPriority {
            newResult.sort { $0.priority < $1.priority }
        }
        newResult.indices.forEach {
            var newObj = newResult[$0]
            newObj.priority = $0
            newResult[$0] = newObj
        }
        self = newResult
    }
}

extension ProfileBasicProtocol {
    public var isValid: Bool {
        true
            && isUIDValid
            && !name.isEmpty
    }

    public var isOfflineProfile: Bool {
        cookie.isEmpty
    }

    public var isInvalid: Bool { !isValid }

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(uid) else { return false }
        /// 绝区零的国服 UID 是八位。
        #if os(watchOS)
        return (100_000_00 ... Int(Int32.max)).contains(givenUIDInt)
        #else
        return (100_000_00 ... 9_999_999_999).contains(givenUIDInt)
        #endif
    }
}

// MARK: - ProfileProtocol

public protocol ProfileProtocol: ProfileBasicProtocol {
    var game: Pizza.SupportedGame { get set }
    var deviceID: String { get set }
    var server: HoYo.Server { get set }
}

extension ProfileProtocol {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}

extension ProfileProtocol {
    public mutating func inherit(from target: some ProfileProtocol) {
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

// MARK: - PZProfileRefProtocol

public protocol PZProfileRefProtocol: AnyObject, ProfileProtocol, Codable {
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
        deviceID: String? = nil
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
