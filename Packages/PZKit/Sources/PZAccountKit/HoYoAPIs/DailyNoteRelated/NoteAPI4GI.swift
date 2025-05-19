// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

extension HoYo {
    public static func note4GI(profile: PZProfileSendable) async throws -> any Note4GI {
        try await note4GI(
            uidWithGame: profile.uidWithGame,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    static func note4GI(
        uidWithGame: String,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> any Note4GI {
        switch server.region {
        case .miyoushe:
            if cookie.contains("stoken=v2_") {
                let firstResult = try? await generalNote4GI(
                    uidWithGame: uidWithGame,
                    server: server,
                    uid: uid,
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint,
                    deviceID: deviceID
                )
                if let firstResult { return firstResult }
                return try await widgetNote4GI(
                    uidWithGame: uidWithGame,
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint,
                    deviceID: deviceID
                )
            } else {
                throw MiHoYoAPIError.sTokenV2InvalidOrMissing
            }
        case .hoyoLab:
            return try await generalNote4GI(
                uidWithGame: uidWithGame,
                server: server,
                uid: uid,
                cookie: cookie,
                deviceFingerPrint: deviceFingerPrint,
                deviceID: deviceID
            )
        }
    }

    static func generalNote4GI(
        uidWithGame: String,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> GeneralNote4GI {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/genshin/api/dailyNote",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let data = try await request.serializingData().value
        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.generalNote4GI()") {
            GeneralNote4GI.CacheSputnik.cache(data, uidWithGame: uidWithGame)
        }
    }

    static func widgetNote4GI(
        uidWithGame: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> WidgetNote4GI {
        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: .miyoushe(.genshinImpact),
            path: "/game_record/app/genshin/aapi/widget/v2",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let data = try await request.serializingData().value
        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.widgetNote4GI()") {
            WidgetNote4GI.CacheSputnik.cache(data, uidWithGame: uidWithGame)
        }
    }
}
