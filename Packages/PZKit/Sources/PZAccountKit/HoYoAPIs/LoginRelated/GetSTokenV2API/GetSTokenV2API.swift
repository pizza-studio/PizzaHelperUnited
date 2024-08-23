// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension HoYo {
    /// 返回STokenV2，需要验证SToken。
    /// 见 [UIGF的文档](https://github.com/UIGF-org/mihoyo-api-collect/blob/main/hoyolab/user/token.md#%E9%80%9A%E8%BF%87stokenv1%E8%8E%B7%E5%8F%96stokenv2)
    public static func sTokenV2(cookie: String) async throws -> String {
        let request = try await generateRequest(
            httpMethod: .post,
            region: .miyoushe(.genshinImpact), // 此处可以乱填游戏名称，因为不影响。
            host: "passport-api.mihoyo.com",
            path: "/account/ma-cn-session/app/getTokenBySToken",
            queryItems: [],
            cookie: cookie,
            additionalHeaders: ["x-rpc-app_id": "bll8iq97cem8"]
        )
        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try RetrievedSTokenV2Result.decodeFromMiHoYoAPIJSONResult(data: data)

        return result.token.token
    }
}

// MARK: - RetrievedSTokenV2Result

private struct RetrievedSTokenV2Result: Decodable, DecodableFromMiHoYoAPIJSONResult {
    struct Token: Decodable {
        let token: String
    }

    let token: Token
}
