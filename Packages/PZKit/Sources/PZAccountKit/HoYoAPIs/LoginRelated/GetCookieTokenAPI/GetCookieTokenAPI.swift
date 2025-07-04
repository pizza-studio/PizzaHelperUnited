// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
extension HoYo {
    /// 返回CookieToken，需要验证SToken。
    public static func cookieToken(
        game: Pizza.SupportedGame,
        cookie: String,
        queryItems: [URLQueryItem] = []
    ) async throws
        -> GetCookieTokenResult {
        let request = try await generateRequest(
            region: .miyoushe(game),
            host: "api-takumi.mihoyo.com",
            path: "/auth/api/getCookieAccountInfoBySToken",
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        let data = try await request.serializingData().value
        let result = try GetCookieTokenResult.decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.cookieToken()")

        return result
    }
}

// MARK: - GetCookieTokenResult

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
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
