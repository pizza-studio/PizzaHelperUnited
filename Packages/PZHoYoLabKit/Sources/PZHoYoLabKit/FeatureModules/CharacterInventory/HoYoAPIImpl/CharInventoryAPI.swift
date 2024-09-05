// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

extension HoYo {
    public static func getCharacterInventory(for profile: PZProfileMO) async throws -> (any CharacterInventory)? {
        #if DEBUG
        print("||| START REQUESTING CHARACTER INVENTORY |||")
        #endif
        return switch profile.game {
        case .genshinImpact: try await characterInventory4GI(
                server: profile.server.withGame(profile.game),
                uid: profile.uid,
                cookie: profile.cookie,
                deviceFingerPrint: profile.deviceFingerPrint,
                deviceId: profile.deviceID
            )
        case .starRail: try await characterInventory4HSR(
                server: profile.server.withGame(profile.game),
                uid: profile.uid,
                cookie: profile.cookie,
                deviceFingerPrint: profile.deviceFingerPrint,
                deviceId: profile.deviceID
            )
        case .zenlessZone: nil
        }
    }

    fileprivate static func characterInventory4GI(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> CharInventory4GI {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                ]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            httpMethod: .post, // 不是 .get。
            region: server.region,
            path: server.region.characterInventoryRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            deviceID: deviceId,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }

    fileprivate static func characterInventory4HSR(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> CharInventory4HSR {
        var queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                ]
            } else {
                return nil
            }
        }()

        var newCookie = cookie
        switch server.region {
        case .miyoushe:
            queryItems.insert(.init(name: "rolePageAccessNotAllowed", value: ""), at: 0)
            let cookieToken = try await cookieToken(game: .starRail, cookie: cookie, queryItems: queryItems)
            newCookie = "account_id=\(cookieToken.uid); cookie_token=\(cookieToken.cookieToken); " + cookie
        case .hoyoLab:
            queryItems.insert(.init(name: "need_wiki", value: "false"), at: 0)
        }

        let request = try await Self.generateRecordAPIRequest(
            httpMethod: .get, // 不是 .post。
            region: server.region,
            path: server.region.characterInventoryRetrievalPath,
            queryItems: queryItems,
            cookie: newCookie,
            deviceID: deviceId,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}

extension HoYo.AccountRegion {
    public var characterInventoryRetrievalPath: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "/game_record/app/genshin/api/character"
        case (.miyoushe, .genshinImpact): "/game_record/app/genshin/api/character"
        case (.hoyoLab, .starRail): "/game_record/app/hkrpg/api/avatar/info"
        case (.miyoushe, .starRail): "/game_record/app/hkrpg/api/avatar/basic"
        case (.hoyoLab, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/basic" // 乱填，暂不实作。
        case (.miyoushe, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/basic" // 乱填，暂不实作。
        }
    }
}
