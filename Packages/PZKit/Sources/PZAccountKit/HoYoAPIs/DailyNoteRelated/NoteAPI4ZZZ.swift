// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

extension HoYo {
    public static func note4ZZZ(profile: PZProfileSendable) async throws -> Note4ZZZ {
        try await getNote4ZZZ(
            uidWithGame: profile.uidWithGame,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    static func getNote4ZZZ(
        uidWithGame: String,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> Note4ZZZ {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]
        var additionalHeaders = [
            "User-Agent": "WidgetExtension/434 CFNetwork/1492.0.1 Darwin/23.3.0",
        ]

        if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
            additionalHeaders.updateValue(deviceFingerPrint, forKey: "x-rpc-device_fp")
            additionalHeaders.updateValue(deviceID, forKey: "x-rpc-device_id")
        }

        let host = switch server.region {
        case .miyoushe: "api-takumi-record.mihoyo.com"
        case .hoyoLab: "sg-act-nap-api.hoyolab.com"
        }

        let request = try await Self.generateRequest(
            region: server.region,
            host: host,
            path: "/event/game_record_zzz/api/zzz/note",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let data = try await request.serializingData().value
        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.getNote4ZZZ") {
            Note4ZZZ.CacheSputnik.cache(data, uidWithGame: uidWithGame)
        }
    }
}
