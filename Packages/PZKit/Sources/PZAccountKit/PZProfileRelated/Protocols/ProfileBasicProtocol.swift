// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - ProfileBasicProtocol

/// AccountMO 不是统一披萨助手引擎用来主要处理的格式，
/// 而是专门为了从 CloudKit 读取既有资料而实作的资料交换格式。
/// 这也是为了方便直接继承旧版原披助手与穹披助手的云端资料。
/// AccountMO 不曝露给前端使用，不直接用于 SwiftUI。

public protocol ProfileBasicProtocol: Codable {
    var allowNotification: Bool { get }
    var cookie: String { get }
    var deviceFingerPrint: String { get }
    var name: String { get }
    var priority: Int { get }
    var serverRawValue: String { get }
    var sTokenV2: String? { get }
    var uid: String { get }
    var uuid: UUID { get }
}

// MARK: - ProfileMOBasicProtocol

public protocol ProfileMOBasicProtocol: Codable, ProfileBasicProtocol {
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

extension Array where Element: ProfileMOBasicProtocol {
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

// MARK: - ProfileMOProtocol

public protocol ProfileMOProtocol: ProfileProtocol, ProfileMOBasicProtocol {
    var game: Pizza.SupportedGame { get set }
    var deviceID: String { get set }
    var server: HoYo.Server { get set }
}

// MARK: - ProfileProtocol

public protocol ProfileProtocol: ProfileBasicProtocol, Identifiable {
    var game: Pizza.SupportedGame { get }
    var deviceID: String { get }
    var server: HoYo.Server { get }
}

extension ProfileProtocol {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}

extension ProfileMOProtocol {
    public mutating func inherit(from target: some ProfileMOProtocol) {
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
