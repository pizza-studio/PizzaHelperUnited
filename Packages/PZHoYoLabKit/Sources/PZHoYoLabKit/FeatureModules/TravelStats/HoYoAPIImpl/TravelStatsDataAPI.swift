// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

extension HoYo {
    public static func getTravelStatsData(for profile: PZProfileSendable) async throws -> (any TravelStats)? {
        switch profile.game {
        case .genshinImpact: try await getTravelStatsData4GI(for: profile)
        case .starRail: try await getTravelStatsData4HSR(for: profile)
        case .zenlessZone: nil
        }
    }
}

extension HoYo {
    static func getTravelStatsData4GI(for profile: PZProfileSendable) async throws -> TravelStatsData4GI {
        try await travelStatsData4GI(
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    static func getTravelStatsData4HSR(for profile: PZProfileSendable) async throws -> TravelStatsData4HSR {
        try await travelStatsData4HSR(
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }
}

extension HoYo {
    private static func travelStatsData4GI(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> TravelStatsData4GI {
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING LEDGER DATA (GI) |||")
        #endif
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

        let request = try await generateRecordAPIRequest(
            httpMethod: .get,
            region: server.region,
            path: server.region.genshinTravelStatsDataRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.travelStatsData4GI()")
    }

    private static func travelStatsData4HSR(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> TravelStatsData4HSR {
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING LEDGER DATA (HSR) |||")
        #endif
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

        let request = try await generateRecordAPIRequest(
            httpMethod: .get,
            region: server.region,
            path: server.region.genshinTravelStatsDataRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.travelStatsData4HSR()")
    }
}

extension HoYo.AccountRegion {
    public var genshinTravelStatsDataRetrievalPath: String {
        switch game {
        case .starRail: "/game_record/app/hkrpg/api/index"
        case .genshinImpact: "/game_record/app/genshin/api/index"
        case .zenlessZone: "/event/game_record_zzz/api/zzz/index"
        }
    }
}
