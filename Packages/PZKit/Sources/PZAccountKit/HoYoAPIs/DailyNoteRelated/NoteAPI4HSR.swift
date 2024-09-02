// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

extension HoYo {
    public static func note4HSR(profile: PZProfileMO) async throws -> Note4HSR {
        try await note4HSR(
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    /// Fetches the daily note of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose daily note to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPIError` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `Note4HSR` that represents the user's daily note.
    static func note4HSR(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> Note4HSR {
        switch server.region {
        case .miyoushe:
            if cookie.contains("stoken=v2_") {
                return try await widgetNote4HSR(
                    cookie: cookie,
                    deviceFingerPrint: deviceFingerPrint,
                    deviceID: deviceID
                )
            } else {
                throw MiHoYoAPIError.sTokenV2InvalidOrMissing
            }
        case .hoyoLab:
            return try await generalNote4HSR(
                server: server,
                uid: uid,
                cookie: cookie,
                deviceFingerPrint: deviceFingerPrint,
                deviceID: deviceID
            )
        }
    }

    /// Fetches the daily note of the specified user.
    ///
    /// - Parameter server: The server where the user's account exists.
    /// - Parameter uid: The uid of the user whose daily note to fetch.
    /// - Parameter cookie: The cookie of the user. This is used for authentication purposes.
    ///
    /// - Throws: An error of type `MiHoYoAPI.Error` if an error occurs while making the API request.
    ///
    /// - Returns: An instance of `GeneralNote4HSR` that represents the user's daily note.
    static func generalNote4HSR(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> GeneralNote4HSR {
//        #if DEBUG
//        return .example()
//        #else
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]
        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                return nil
            }
        }()
        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: "/game_record/app/hkrpg/api/note",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
//        #endif
    }

    /// Fetches the daily note of the specified user. Using widget api.
    /// - Parameters:
    ///   - cookie: The cookie of the user.
    ///   - deviceFingerPrint: The device finger print of the user.
    static func widgetNote4HSR(
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> WidgetNote4HSR {
        var additionalHeaders = [
            "User-Agent": "WidgetExtension/434 CFNetwork/1492.0.1 Darwin/23.3.0",
        ]

        if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
            additionalHeaders.updateValue(deviceFingerPrint, forKey: "x-rpc-device_fp")
            additionalHeaders.updateValue(deviceID, forKey: "x-rpc-device_id")
        }

        let request = try await Self.generateRecordAPIRequest(
            region: .miyoushe(.starRail),
            path: "/game_record/app/hkrpg/aapi/widget",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}
