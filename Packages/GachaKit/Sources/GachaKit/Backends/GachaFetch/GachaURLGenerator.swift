// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZAccountKit
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, *)
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

        // NOTE: hostDomain is not the one for public operations.
        let hostDomain = switch profile.server.region {
        case .hoyoLab: "api-global-takumi.mihoyo.com"
        case .miyoushe: "api-takumi.mihoyo.com"
        }

        let baseURL = "https://\(hostDomain)/binding/api/genAuthKey"

        var deviceID = profile.deviceID
        if deviceID.isEmpty {
            let newDeviceID = await ThisDevice.identifier4Vendor
            deviceID = newDeviceID
        }

        let headers: HTTPHeaders = [
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

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        var theDataStr = ""
        do {
            let data = try await AF.request(
                baseURL,
                method: .post,
                parameters: genAuthKeyParam,
                encoder: JSONParameterEncoder(encoder: encoder),
                headers: headers
            )
            .serializingData().value
            // 注：此处没有用 AF 的 API 来解码，是为了在错误讯息里面印出伺服器传回的原文。
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

        let host = URLRequestConfig.domain4PublicOps(region: server.region)
        let path = URLRequestConfig.gachaRecordAPIPath(game: server.game)
        let baseURL = "https://\(host)\(path)"

        // 使用參數字典而非URLComponents
        var parameters = [String: String]()
        parameters["authkey_ver"] = authkey.authkeyVer.description
        parameters["sign_type"] = authkey.signType.description
        parameters["auth_appid"] = "webview_gacha"
        parameters["win_mode"] = "fullscreen"
        parameters["timestamp"] = "\(Int(Date().timeIntervalSince1970))"
        parameters["region"] = server.rawValue
        parameters["default_gacha_type"] = gachaTypeStr
        parameters["lang"] = LANG
        parameters["game_biz"] = gameBiz
        parameters["os_system"] = "iOS 16.6"
        parameters["device_model"] = "iPhone15.2"
        parameters["plat_type"] = "ios"
        parameters["page"] = String(page)
        parameters["size"] = "20"
        parameters["gacha_type"] = gachaTypeStr
        parameters["real_gacha_type"] = gachaTypeStr
        parameters["end_id"] = endId
        parameters["authkey"] = authkey.authkey

        // 組裝完整URL字串
        let urlRequest = try URLRequest(url: baseURL, method: .get)
        let encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        guard let url = encodedURLRequest.url else {
            throw GenGachaURLError.genURLError(message: "Failed to generate URL with parameters")
        }

        return url.absoluteString
    }
}
