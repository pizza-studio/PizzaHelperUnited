// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

extension HoYo {
    public static func getTravelStatsData4GI(for profile: PZProfileMO) async throws -> TravelStatsData4GI {
        try await getTravalStatsData4GI(
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    public static func getTravalStatsData4GI(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> TravelStatsData4GI {
        #if DEBUG
        print("||| START REQUESTING LEDGER DATA (GI) |||")
        #endif
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

        let request = try await generateRecordAPIRequest(
            httpMethod: .get,
            region: server.region,
            path: server.region.genshinTravelStatsDataRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        #if DEBUG
        print("---------------------------------------------")
        print(request.debugDescription)
        if let headerEX = request.allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try! encoder.encode(headerEX), encoding: .utf8)!)
        }
        print("---------------------------------------------")
        #endif

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}

extension HoYo.AccountRegion {
    public var genshinTravelStatsDataRetrievalPath: String {
        "/game_record/app/genshin/api/index"
    }
}
