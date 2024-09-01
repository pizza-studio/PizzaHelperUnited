// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension HoYo {
    /// 返回CookieToken，需要验证SToken。
    public static func cookieToken(
        cookie: String,
        queryItems: [URLQueryItem] = []
    ) async throws
        -> GetCookieTokenResult {
        let request = try await generateRequest(
            region: .miyoushe(.genshinImpact), // 此处可以乱填游戏名称，因为不影响。
            host: "api-takumi.mihoyo.com",
            path: "/auth/api/getCookieAccountInfoBySToken",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try GetCookieTokenResult.decodeFromMiHoYoAPIJSONResult(data: data)

        return result
    }
}

// MARK: - GetCookieTokenResult

public struct GetCookieTokenResult: Decodable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cookieToken = try container.decode(String.self, forKey: .cookieToken)
        self.uid = try container.decode(String.self, forKey: .uid)
    }

    // MARK: Public

    public let cookieToken: String
    public let uid: String

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case cookieToken = "cookie_token"
        case uid
    }
}
