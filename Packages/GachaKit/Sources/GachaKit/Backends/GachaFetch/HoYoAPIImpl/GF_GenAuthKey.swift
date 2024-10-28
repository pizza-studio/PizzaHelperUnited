// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension HoYo {
    public static func generateGIGachaURLByMiyousheAPI(
        _ profile: PZProfileSendable
    ) async throws
        -> String {
        do {
            let result = try await generateAuthenticationKey4GI(profile: profile)
            if result.retcode == 0, let resultData = result.data {
                let urlString = HoYo.assembleMiyousheGIGachaURLByAPI(
                    server: profile.server,
                    authkey: resultData,
                    gachaType: .characterEventWish1,
                    page: 1,
                    endId: "0"
                )
                return urlString
            } else {
                throw GenGachaURLError.genURLError(
                    message: "fail to get auth key: \(result.message)"
                )
            }
        } catch {
            if error is GenGachaURLError {
                throw error
            }
            throw GenGachaURLError.genURLError(
                message: "fail to get auth key: \(error)"
            )
        }
    }

    private static func generateAuthenticationKey4GI(
        profile: PZProfileSendable
    ) async throws
        -> GenAuthKeyResult {
        if case .hoyoLab = profile.server.region {
            throw GetGachaError.unknownError(
                retcode: -213,
                message: "HoYo.genAuthKey4GI is for Miyoushe only."
            )
        }
        let gameBiz: String = profile.server.region.rawValue
        let genAuthKeyParam = GenAuthKeyParam(
            gameUid: profile.uid,
            serverRawValue: profile.server.rawValue,
            gameBiz: gameBiz
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestBody = try! encoder.encode(genAuthKeyParam)

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api-takumi.mihoyo.com"

        urlComponents.path = "/binding/api/genAuthKey"

        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBody

        print(request)

        request.allHTTPHeaderFields = [
            "Content-Type": "application/json; charset=utf-8",
            "Host": "api-takumi.mihoyo.com",
            "Accept": "application/json, text/plain, */*",
            "Referer": "https://webstatic.mihoyo.com",
            "x-rpc-app_version": "2.71.1",
            "x-rpc-client_type": "5",
            "x-rpc-device_id": await ThisDevice.identifier4Vendor,
            "x-requested-with": "com.mihoyo.hyperion",
            "Cookie": profile.cookie,
            "DS": getDSTokenForGachaRecords(region: profile.server.region),
        ]

        print(request.allHTTPHeaderFields!)
        print(String(data: requestBody, encoding: .utf8)!)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(GenAuthKeyResult.self, from: data)
            return result
        } catch {
            throw GetGachaError.genAuthKeyError(message: "\(error)")
        }
    }

    static func getDSTokenForGachaRecords(region: HoYo.AccountRegion) -> String {
        /// The following salts are LK2. Intelligence provided by qhy040404.
        /// LK2 is at least dedicated for the task in this file.
        let s = switch region {
        case .miyoushe: "EJncUPGnOHajenjLhBOsdpwEMZmiCmQX"
        case .hoyoLab: "rk4xg2hakoi26nljpr099fv9fck1ah10"
        }
        if case .hoyoLab = region {
            assert(false, "CanglongCI wants a crash here.")
        }
        let t = String(Int(Date().timeIntervalSince1970))
        let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyz1234567890"
        let r = String((0 ..< 6).map { _ in
            lettersAndNumbers.randomElement()!
        })
        let c = "salt=\(s)&t=\(t)&r=\(r)".md5
        print(t + "," + r + "," + c)
        print("salt=\(s)&t=\(t)&r=\(r)")
        return t + "," + r + "," + c
    }
}

// MARK: - GetCookieTokenResult

private struct GetCookieTokenResult: Codable {
    struct GetCookieTokenData: Codable {
        let uid: String
        let cookieToken: String
    }

    let retcode: Int
    let message: String
    let data: GetCookieTokenData?
}

// MARK: - GenAuthKeyParam

private struct GenAuthKeyParam: Encodable {
    // MARK: Internal

    let authAppid: String = "webview_gacha"
    let gameUid: String
    let serverRawValue: String
    let gameBiz: String

    // MARK: Fileprivate

    fileprivate func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(authAppid, forKey: .authAppid)
        try container.encode(gameUid, forKey: .gameUid)
        try container.encode(serverRawValue, forKey: .serverRawValue)
        try container.encode(gameBiz, forKey: .gameBiz)
    }

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case authAppid
        case gameUid
        case serverRawValue = "region"
        case gameBiz
    }
}

// MARK: - GenAuthKeyResult

public struct GenAuthKeyResult: Codable {
    // MARK: Public

    public struct GenAuthKeyData: Codable {
        let authkeyVer: Int
        let signType: Int
        let authkey: String
    }

    // MARK: Internal

    let retcode: Int
    let message: String
    let data: GenAuthKeyData?
}

extension HoYo {
    private static func assembleMiyousheGIGachaURLByAPI(
        server: HoYo.Server,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        gachaType: GachaTypeGI,
        page: Int,
        endId: String
    )
        -> String {
        let gameBiz: String = server.region.rawValue
        let LANG = "zh-cn"
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = switch server.region {
        case .miyoushe: "public-operation-hk4e.mihoyo.com"
        case .hoyoLab: "public-operation-hk4e-sg.hoyoverse.com"
        }
        urlComponents.path = "/gacha_info/api/getGachaLog"
        let gameVersion = switch server.region {
        case .miyoushe: "CNRELWin5.0.0_R26885261_S27370672_D27173400"
        case .hoyoLab: "OSRELWin5.0.0_R26458901_S26368837_D26487341"
        }

        urlComponents.queryItems = [
            .init(name: "win_mode", value: "fullscreen"),
            .init(name: "authkey_ver", value: String(authkey.authkeyVer)),
            .init(name: "sign_type", value: String(authkey.signType)),
            .init(name: "auth_appid", value: "webview_gacha"),
            .init(name: "init_type", value: "301"),
            .init(
                name: "gacha_id",
                value: "9e72b521e716d347e3027a4f71efc08f1455d4b2"
            ),
            .init(
                name: "timestamp",
                value: String(Int(Date().timeIntervalSince1970))
            ),
            .init(name: "lang", value: LANG),
            .init(name: "device_type", value: "mobile"),
            .init(
                name: "game_version",
                value: gameVersion
            ),
            .init(name: "plat_type", value: "ios"),
            .init(name: "region", value: server.rawValue),
        ]

        var urlString = urlComponents.url!.absoluteString

        urlString += "&authkey=\(authkey.authkey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)"

        let restOfQueryItems: [URLQueryItem] = [
            .init(name: "game_biz", value: gameBiz),
            .init(name: "gacha_type", value: String(gachaType.rawValue)),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: "20"),
            .init(name: "end_id", value: endId),
        ]
        restOfQueryItems.forEach { item in
            urlString += "&\(item.name)=\(item.value!)"
        }
        return urlString
    }
}
