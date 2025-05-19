// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation

extension HoYo {
    public static func getUserGameRolesByCookie(
        region: AccountRegion,
        cookie: String
    ) async throws
        -> [FetchedAccount] {
        let queryItems: [URLQueryItem] = [
            .init(name: "game_biz", value: region.rawValue),
        ]

        let request = try await Self.generateAccountAPIRequest(
            region: region,
            path: "/binding/api/getUserGameRolesByCookie",
            queryItems: queryItems,
            cookie: cookie
        )

        let data = try await request.serializingData().value
        let list = try FetchedAccountDecodeHelper.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HoYo.getUserGameRolesByCookie()"
        )
        return list.list
    }
}
