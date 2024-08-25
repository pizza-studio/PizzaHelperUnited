// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

extension HoYo {
    public static func note4GI(profile: PZProfileMO) async throws -> any Note4GI {
        try await note4GI(
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint
        )
    }

    static func note4GI(
        server: Server,
        uid: String,
        cookie: String,
        sTokenV2: String? = nil,
        deviceFingerPrint: String?,
        deviceId: String? = ThisDevice.identifier4Vendor
    ) async throws
        -> any Note4GI {
        let deviceFingerPrint = deviceFingerPrint ?? ThisDevice.identifier4Vendor
        switch server.region {
        case .miyoushe:
            if let sTokenV2 {
                return try await widgetNote4GI(
                    cookie: cookie,
                    sTokenV2: sTokenV2,
                    deviceFingerPrint: deviceFingerPrint,
                    deviceId: deviceId
                )
            } else if cookie.contains("stoken=v2_") {
                return try await widgetNote4GI(
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint,
                    deviceId: deviceId
                )
            } else {
                throw MiHoYoAPIError.sTokenV2InvalidOrMissing
            }
        case .hoyoLab:
            return try await generalNote4GI(
                server: server,
                uid: uid,
                cookie: cookie,
                deviceFingerPrint: deviceFingerPrint,
                deviceId: deviceId
            )
        }
    }

    static func generalNote4GI(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> GeneralNote4GI {
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.id),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceId {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceId,
                ]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/genshin/api/dailyNote",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }

    static func widgetNote4GI(
        cookie: String,
        sTokenV2: String = "",
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> WidgetNote4GI {
        var cookie = cookie + "stoken: \(sTokenV2)"
        if !cookie.contains("stoken=v2_"), !sTokenV2.isEmpty {
            cookie += "stoken: \(sTokenV2)"
        }
        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceId {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceId,
                ]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: .miyoushe(.genshinImpact),
            path: "/game_record/app/genshin/aapi/widget/v2",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try await .decodeFromMiHoYoAPIJSONResult(data: data, with: request)
    }
}
