// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.PassportTokenType

extension HoYo {
    /// 通行证 V2 换票接口的凭据类型。
    public enum PassportTokenType: Int, Sendable {
        /// `stoken` 本身，仅作换票的源头凭据。
        case stoken = 1
        /// 网页端 `ltoken_v2`。
        case ltoken = 2
        /// 网页端 `cookie_token_v2`。
        case cookieToken = 4
    }
}

// MARK: - HoYo.PassportTokenExchangeResult

extension HoYo {
    /// 通行证 V2 换票结果。
    public struct PassportTokenExchangeResult: DecodableFromMiHoYoAPIJSONResult, Sendable {
        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let token = try container.decode(TokenPayload.self, forKey: .token)
            let tokenValue = token.token.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !tokenValue.isEmpty else {
                throw MiHoYoAPIError.other(retcode: -9999, message: "通行证换票响应缺少有效凭据。")
            }
            let userInfo = try container.decodeIfPresent(UserInfoPayload.self, forKey: .userInfo)
            self.token = tokenValue
            self.tokenType = token.tokenType?.intValue
            self.uid = userInfo?.aid?.stringValue ?? userInfo?.uid?.stringValue
            self.expireInSeconds = try container.decodeIfPresent(StringOrInt.self, forKey: .expireInSeconds)?.intValue
        }

        // MARK: Public

        /// 换到的凭据本体。
        public let token: String
        /// 服务端回传的凭据类型。
        public let tokenType: Int?
        /// 凭据所属的米游社账号 ID。
        public let uid: String?
        /// 凭据的有效期（秒）。
        public let expireInSeconds: Int?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case token
            case userInfo = "user_info"
            case expireInSeconds = "expire_in_seconds"
        }

        struct TokenPayload: Decodable {
            enum CodingKeys: String, CodingKey {
                case token
                case tokenType = "token_type"
            }

            let token: String
            let tokenType: StringOrInt?
        }

        struct UserInfoPayload: Decodable {
            let aid: StringOrInt?
            let uid: StringOrInt?
        }

        /// 服务端在不同接口间会混用字符串与整数形式回传数值，例如 `expire_in_seconds` 恒为字符串。
        struct StringOrInt: Decodable, Sendable {
            // MARK: Lifecycle

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let value = try? container.decode(String.self) {
                    self.stringValue = value
                } else if let value = try? container.decode(Int.self) {
                    self.stringValue = String(value)
                } else {
                    throw DecodingError.typeMismatch(
                        String.self,
                        .init(
                            codingPath: container.codingPath,
                            debugDescription: "Expected a String or an Int."
                        )
                    )
                }
            }

            // MARK: Internal

            let stringValue: String

            var intValue: Int? { Int(stringValue) }
        }
    }
}

// MARK: - HoYo.exchangePassportToken

extension HoYo {
    /// 使用通行证 V2 接口将 `stoken` 换成指定凭据。
    ///
    /// 旧的 `account/auth/api/getLTokenBySToken` 与 `getCookieAccountInfoBySToken`
    /// 已自 2026-11-20 起被服务端停用，现行流程一律走 `account/ma-cn-session/app/exchange`。
    /// - Parameters:
    ///   - stoken: 米游社 `stoken`。
    ///   - mid: 米游社账号的 `mid`。
    ///   - target: 目标凭据类型。
    ///   - deviceID: 设备 ID，缺省时使用本机 IDFV。
    ///   - deviceFP: 设备指纹。
    /// - Returns: 换票结果。
    public static func exchangePassportToken(
        stoken: String,
        mid: String,
        target: PassportTokenType,
        deviceID: String? = nil,
        deviceFP: String? = nil
    ) async throws
        -> PassportTokenExchangeResult {
        let stoken = stoken.trimmingCharacters(in: .whitespacesAndNewlines)
        let mid = mid.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !stoken.isEmpty, !mid.isEmpty else {
            throw MiHoYoAPIError.other(retcode: -9999, message: "通行证换票所需的 stoken 或 mid 缺失。")
        }

        let body = try exchangeRequestBody(stoken: stoken, mid: mid, target: target)

        var request = URLRequest(url: exchangeURL)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.allHTTPHeaderFields = exchangeHeaders(deviceID: deviceID, deviceFP: deviceFP)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            URLRequestHelper.getSignedBodyDS(salt: URLRequestConfig.passportTokenExchangeSalt, body: body),
            forHTTPHeaderField: "DS"
        )
        request.httpBody = Data(body.utf8)

        let data = try await AF.request(request).serializingData().value
        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.exchangePassportToken()")
    }

    /// 使用已解析的米游社账号凭据换票。
    /// - Parameters:
    ///   - cookie: 米游社账号凭据。
    ///   - target: 目标凭据类型。
    ///   - deviceID: 设备 ID，缺省时使用本机 IDFV。
    ///   - deviceFP: 设备指纹。
    /// - Returns: 换票结果。
    public static func exchangePassportToken(
        cookie: MiyousheCookie,
        target: PassportTokenType,
        deviceID: String? = nil,
        deviceFP: String? = nil
    ) async throws
        -> PassportTokenExchangeResult {
        try await exchangePassportToken(
            stoken: cookie.stoken,
            mid: cookie.mid,
            target: target,
            deviceID: deviceID,
            deviceFP: deviceFP
        )
    }

    // MARK: Internal

    /// 换票接口与米游社 App 使用同一组 App 端请求头，通用于全部米游社游戏。
    static func exchangeHeaders(deviceID: String?, deviceFP: String?) -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json",
            "User-Agent": URLRequestConfig.miyousheAppUserAgent,
            "x-rpc-app_version": URLRequestConfig.miyousheAppVersion,
            "x-rpc-client_type": "2",
            "x-rpc-app_id": "bll8iq97cem8",
            "x-rpc-game_biz": "bbs_cn",
            "x-rpc-device_id": ThisDevice.getDeviceID4Vendor(deviceID),
            "x-rpc-device_model": ThisDevice.modelIdentifier,
            "x-rpc-sys_version": URLRequestConfig.miyousheAppSystemVersion,
            "x-rpc-sdk_version": URLRequestConfig.passportSDKVersion,
            "x-rpc-account_version": URLRequestConfig.passportSDKVersion,
            "x-rpc-lifecycle_id": lifecycleID,
        ]
        if let deviceFP, !deviceFP.isEmpty {
            headers["x-rpc-device_fp"] = deviceFP
        }
        return headers
    }

    /// 把 JSON 正文里会干扰 JS 解析字符转成 `\uXXXX`，签名与送出必须是同一份字符串。
    static func escapedExchangeBody(_ json: String) -> String {
        json.unicodeScalars.reduce(into: "") { result, scalar in
            switch scalar {
            case "'", "\u{2028}", "\u{2029}", "&", "<", "=", ">":
                result += String(format: "\\u%04x", scalar.value)
            default:
                result.append(Character(scalar))
            }
        }
    }

    static func exchangeRequestBody(
        stoken: String,
        mid: String,
        target: PassportTokenType
    ) throws
        -> String {
        let payload = ExchangeRequestBody(
            dstTokenType: target.rawValue,
            srcToken: .init(token: stoken, tokenType: PassportTokenType.stoken.rawValue),
            mid: mid
        )
        let json = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
        return escapedExchangeBody(json)
    }

    // MARK: Private

    private static let exchangeURL = URL(
        string: "https://passport-api.mihoyo.com/account/ma-cn-session/app/exchange"
    )!

    /// 同一进程内固定，与米游社 App 的进程生命周期 ID 行为一致。
    private static let lifecycleID: String = UUID().uuidString.lowercased()

    private struct ExchangeRequestBody: Encodable {
        struct SourceToken: Encodable {
            enum CodingKeys: String, CodingKey {
                case token
                case tokenType = "token_type"
            }

            let token: String
            let tokenType: Int
        }

        enum CodingKeys: String, CodingKey {
            case dstTokenType = "dst_token_type"
            case srcToken = "src_token"
            case mid
        }

        let dstTokenType: Int
        let srcToken: SourceToken
        let mid: String
    }
}
