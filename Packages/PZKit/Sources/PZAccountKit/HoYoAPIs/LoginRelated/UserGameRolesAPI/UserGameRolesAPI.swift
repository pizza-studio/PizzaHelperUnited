// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

extension HoYo {
    /// 依账号区域取得该账号在指定游戏下已绑定的角色。
    public static func getUserGameRoles(
        region: AccountRegion,
        cookie: String,
        deviceID: String? = nil,
        deviceFP: String? = nil
    ) async throws
        -> [FetchedAccount] {
        switch region {
        case .miyoushe:
            // 米游社的 stoken 路由一次回传该账号在所有游戏下的角色。
            try await getUserGameRolesByStoken(cookie: cookie, deviceID: deviceID, deviceFP: deviceFP)
                .filter { $0.gameBiz == region.rawValue }
        case .hoyoLab:
            try await getUserGameRolesByCookie(region: region, cookie: cookie)
        }
    }

    /// 使用米游社 `stoken` 取得该账号已绑定的全部游戏角色（跨游戏，需要时自行按 `gameBiz` 过滤）。
    ///
    /// 网页端的 `getUserGameRolesByCookie` 依赖已被废弃的 `cookie_token`，故米游社一律走这条 App 端路由。
    public static func getUserGameRolesByStoken(
        cookie: String,
        deviceID: String? = nil,
        deviceFP: String? = nil
    ) async throws
        -> [FetchedAccount] {
        let cookie = MiyousheCookie(cookieString: cookie)
        guard cookie.hasSTokenCredentials else {
            throw MiHoYoAPIError.other(retcode: -9999, message: "登录凭据不完整，请重新登录后重试。")
        }

        var headers: [String: String] = [
            "User-Agent": URLRequestConfig.miyousheAppUserAgent,
            "Referer": "https://webstatic.mihoyo.com",
            "X-Requested-With": "com.mihoyo.hyperion",
            "x-rpc-app_version": URLRequestConfig.miyousheAppVersion,
            "x-rpc-client_type": "2",
            "x-rpc-device_id": ThisDevice.getDeviceID4Vendor(deviceID),
            "DS": URLRequestHelper.getAppSignDS(salt: URLRequestConfig.miyousheAppSignSalt),
            "Cookie": cookie.appSigningCookieHeader,
        ]
        if let deviceFP, !deviceFP.isEmpty {
            headers["x-rpc-device_fp"] = deviceFP
        }

        var request = URLRequest(url: miyousheGameRolesByStokenURL)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.allHTTPHeaderFields = headers

        let data = try await AF.request(request).serializingData().value
        let list = try FetchedAccountDecodeHelper.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HoYo.getUserGameRolesByStoken()"
        )
        return list.list
    }

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

    private static let miyousheGameRolesByStokenURL = URL(
        string: "https://api-takumi.miyoushe.com/binding/api/getUserGameRolesByStoken"
    )!
}
