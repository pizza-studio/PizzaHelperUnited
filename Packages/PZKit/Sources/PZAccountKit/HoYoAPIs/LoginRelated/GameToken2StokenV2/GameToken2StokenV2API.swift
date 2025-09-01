// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

extension HoYo {
    public static func gameToken2StokenV2(accountId: String, gameToken: String) async throws -> GameToken2StokenV2Data {
        struct Body: Encodable {
            let accountId: Int
            let gameToken: String

            enum CodingKeys: String, CodingKey {
                case accountId = "account_id"
                case gameToken = "game_token"
            }
        }

        let headers: HTTPHeaders = [
            "x-rpc-app_id": "bll8iq97cem8",
        ]

        let body = Body(accountId: Int(accountId)!, gameToken: gameToken)

        let data = try await AF.request(
            "https://api-takumi.mihoyo.com/account/ma-cn-session/app/getTokenByGameToken",
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: headers
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.gameToken2StokenV2()")
    }

    public static func stoken2LTokenV1(mid: String, stoken: String) async throws -> Stoken2LTokenV1Data {
        let headers: HTTPHeaders = [
            "cookie": "mid=\(mid); stoken=\(stoken); ",
        ]

        let data = try await AF.request(
            "https://passport-api.mihoyo.com/account/auth/api/getLTokenBySToken",
            method: .get,
            headers: headers
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.stoken2LTokenV1()")
    }
}
