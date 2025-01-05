// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension HoYo {
    static func generateGachaURL(_ profile: PZProfileSendable) async throws -> String {
        do {
            let result: HoYo.GenAuthKeyResult = switch profile.game {
            case .zenlessZone: throw GenGachaURLError.genURLError(
                    message: "ZenlessZoneZero is not supported for generating Gacha URLs."
                )
            case .genshinImpact, .starRail:
                try await generateAuthKey(for: profile)
            }
            guard result.retcode == 0, let resultData = result.data else {
                throw GenGachaURLError.genURLError(
                    message: "fail to get auth key: \(result.message)"
                )
            }

            let urlString = try HoYo.assembleGachaURL(
                server: profile.server,
                authkey: resultData,
                page: 1,
                endId: "0"
            )
            return urlString
        } catch {
            if error is GenGachaURLError {
                throw error
            }
            throw GenGachaURLError.genURLError(
                message: "fail to get auth key: \(error)"
            )
        }
    }
}

extension HoYo {
    private static func generateAuthKey(
        for profile: PZProfileSendable
    ) async throws
        -> GenAuthKeyResult {
        // NOTE: The generated result for HSR is still not usable yet.
        // Either the salt in getDSTokenForGachaRecords or the hostDomain below needs fix.
        // The fix must be game-specific.
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
        // NOTE: hostDomain is not the one for public operations.
        let hostDomain = switch profile.server.region {
        case .hoyoLab: "api-global-takumi.mihoyo.com"
        case .miyoushe: "api-takumi.mihoyo.com"
        }
        urlComponents.host = hostDomain
        urlComponents.path = "/binding/api/genAuthKey"

        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBody

        print(request)

        var deviceID = profile.deviceID
        if deviceID.isEmpty {
            let newDeviceID = await ThisDevice.identifier4Vendor
            deviceID = newDeviceID
        }

        request.allHTTPHeaderFields = [
            "Content-Type": "application/json; charset=utf-8",
            "Host": hostDomain,
            "Accept": "application/json, text/plain, */*",
            "Referer": URLRequestConfig.referer(region: profile.server.region),
            "x-rpc-app_version": URLRequestConfig.xRPCAppVersion4Gacha(region: profile.server.region),
            "x-rpc-client_type": URLRequestConfig.xRPCClientType(region: profile.server.region),
            "x-rpc-device_id": deviceID,
            "x-requested-with": URLRequestConfig.xRequestedWith(region: profile.server.region),
            "Cookie": profile.cookie,
            "DS": getDSTokenForGachaRecords(region: profile.server.region),
        ]

        print(request.allHTTPHeaderFields!)
        print(String(data: requestBody, encoding: .utf8)!)
        var theDataStr = ""
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            theDataStr = String(data: data, encoding: .utf8) ?? ""
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(GenAuthKeyResult.self, from: data)
            return result
        } catch {
            throw GetGachaError.genAuthKeyError(message: "\(error) \n // \(theDataStr)")
        }
    }

    private static func assembleGachaURL(
        server: HoYo.Server,
        authkey: GenAuthKeyResult.GenAuthKeyData,
        page: Int,
        endId: String
    ) throws
        -> String {
        let zzzErrorMsg = "ZenlessZoneZero is not supported for generating Gacha URLs."
        let gameBiz: String = server.region.rawValue

        let LANG: String = switch server.game {
        case .genshinImpact: GachaLanguage.langCHS.rawValue
        case .starRail: GachaLanguage.current.rawValue
        case .zenlessZone: throw GenGachaURLError.genURLError(message: zzzErrorMsg)
        }

        let gachaTypeStr: String = switch server.game {
        case .zenlessZone: throw GenGachaURLError.genURLError(message: zzzErrorMsg)
        case .genshinImpact: GachaTypeGI.knownCases[0].rawValue
        case .starRail: GachaTypeHSR.knownCases[0].rawValue
        }

        let gachaID = URLRequestConfig.gachaGameTypeAuthID(game: server.game)

        var components = URLComponents()
        components.scheme = "https"
        components.host = URLRequestConfig.domain4PublicOps(region: server.region)
        components.path = URLRequestConfig.gachaRecordAPIPath(game: server.game)
        components.queryItems = [
            .init(name: "authkey_ver", value: authkey.authkeyVer.description),
            .init(name: "sign_type", value: authkey.signType.description),
            .init(name: "auth_appid", value: "webview_gacha"),
            .init(name: "win_mode", value: "fullscreen"),
            .init(name: "gacha_id", value: gachaID),
            .init(name: "timestamp", value: "\(Int(Date().timeIntervalSince1970))"),
            .init(name: "region", value: server.rawValue),
            .init(name: "default_gacha_type", value: gachaTypeStr),
            .init(name: "lang", value: LANG),
            .init(name: "game_biz", value: gameBiz),
            .init(name: "os_system", value: "iOS 16.6"),
            .init(name: "device_model", value: "iPhone15.2"),
            .init(name: "plat_type", value: "ios"),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: "20"),
            .init(name: "gacha_type", value: gachaTypeStr),
            .init(name: "real_gacha_type", value: gachaTypeStr),
            .init(name: "end_id", value: endId),
        ]

        let authKeyPercEncoded = authkey.authkey.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
        )!
        // 注意：不能直接将 AuthKey 塞入 URLQueryItem，否则会破坏 AuthKey。这里得用手动编码。
        let urlString = components.url!.absoluteString + "&authkey=\(authKeyPercEncoded)"
        return urlString
    }
}
