// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - URLRequestConfig

/// Abstract class storing salt, version, etc for API.
public enum URLRequestConfig {
    public static func getUserAgent(region: HoYo.AccountRegion) -> String {
        """
        Mozilla/5.0 (iPhone; CPU iPhone OS 17_6 like Mac OS X) \
        AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/\(Self.xRPCAppVersion(region: region))
        """
    }

    public static func ledgerAPIURLHost(region: HoYo.AccountRegion) -> String {
        switch (region, region.game) {
        case (.miyoushe, .genshinImpact): "hk4e-api.mihoyo.com"
        case (.hoyoLab, .genshinImpact): "sg-hk4e-api.hoyolab.com"
        case (.miyoushe, .starRail): "api-takumi.mihoyo.com"
        case (.hoyoLab, .starRail): "sg-public-api.hoyolab.com"
        case (.miyoushe, .zenlessZone): "" // 尚无该功能可用。
        case (.hoyoLab, .zenlessZone): "" // 尚无该功能可用。
        }
    }

    public static func recordURLAPIHost(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "api-takumi-record.mihoyo.com"
        case .hoyoLab: "bbs-api-os.hoyolab.com"
        }
    }

    public static func accountAPIURLHost(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "api-takumi.mihoyo.com"
        case .hoyoLab: "api-account-os.hoyolab.com"
        }
    }

    public static func hostInHeaders(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "https://api-takumi-record.mihoyo.com/"
        case .hoyoLab: "https://bbs-api-os.hoyolab.com/"
        }
    }

    public static func salt(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs" // X4
        case .hoyoLab: "okr4obncj8bw5a65hbnn5oo6ixjc3l9w" // OSX6
        }
    }

    public static func domain4PublicOps(region: HoYo.AccountRegion) -> String {
        switch (region, region.game) {
        case (.miyoushe, .genshinImpact): "public-operation-hk4e.mihoyo.com"
        case (.hoyoLab, .genshinImpact): "public-operation-hk4e-sg.hoyoverse.com"
        case (.miyoushe, .starRail): "public-operation-hkrpg.mihoyo.com"
        case (.hoyoLab, .starRail): "public-operation-hkrpg-sg.hoyoverse.com"
        case (.miyoushe, .zenlessZone): "public-operation-nap.mihoyo.com"
        case (.hoyoLab, .zenlessZone): "public-operation-nap-sg.hoyoverse.com"
        }
    }

    public static func xRPCAppVersion(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "2.40.1" // 跟 YunzaiBot 一致。
        case .hoyoLab: "2.55.0" // 跟 YunzaiBot 一致。
        }
    }

    public static func xRPCClientType(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "5"
        case .hoyoLab: "2"
        }
    }

    public static func referer(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "https://webstatic.mihoyo.com"
        case .hoyoLab: "https://act.hoyolab.com"
        }
    }

    public static func origin(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "https://webstatic.mihoyo.com"
        case .hoyoLab: "https://act.hoyolab.com"
        }
    }

    public static func xRequestedWith(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "com.mihoyo.hyperion"
        case .hoyoLab: "com.mihoyo.hoyolab"
        }
    }

    public static func xRPCLanguage(region: HoYo.AccountRegion) -> String {
        switch (region, region.game) {
        case (.miyoushe, .starRail): HoYo.APILang.langCHS.rawValue
        default: HoYo.APILang.current.rawValue
        }
    }

    /// Get unfinished default headers containing host, api-version, etc.
    /// You need to add `DS` field using `URLRequestHelper.getDS` manually
    /// - Parameter region: the region of the account
    /// - Returns: http request headers
    public static func defaultHeaders(
        region: HoYo.AccountRegion,
        deviceID: String?,
        additionalHeaders: [String: String]?
    ) async throws
        -> [String: String] {
        let deviceID: String = if #available(macCatalyst 15.0, *) {
            await ThisDevice.getDeviceID4Vendor(deviceID)
        } else {
            UUID().uuidString
        }
        var headers = [
            "User-Agent": Self.getUserAgent(region: region),
            "Referer": referer(region: region),
            "Origin": origin(region: region),
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "application/json, text/plain, */*",
            "Connection": "keep-alive",

            "X-Requested-With": xRequestedWith(region: region),
            "x-rpc-app_version": xRPCAppVersion(region: region),
            "x-rpc-client_type": xRPCClientType(region: region),
            "x-rpc-page": "3.1.3_#/rpg",
            "x-rpc-device_id": deviceID,
            "x-rpc-language": xRPCLanguage(region: region),

            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Site": "same-site",
            "Sec-Fetch-Mode": "cors",
        ]
        if let additionalHeaders, !additionalHeaders.isEmpty {
            headers.merge(additionalHeaders, uniquingKeysWith: { $1 })
        }
        return headers
    }
}

extension URLRequestConfig {
    public static func writeXRPCChallengeHeaders4DailyNote(
        to target: inout [String: String],
        for region: HoYo.AccountRegion
    ) {
        guard case .miyoushe = region else { return }
        switch region.game {
        case .genshinImpact:
            let header = "https://api-takumi-record.mihoyo.com/game_record/app/"
            target["x-rpc-challenge_path"] = "\(header)genshin/api/dailyNote"
            target["x-rpc-challenge_game"] = "2"
        case .starRail:
            let header = "https://api-takumi-record.mihoyo.com/game_record/app/"
            target["x-rpc-challenge_path"] = "\(header)hkrpg/api/note"
            target["x-rpc-challenge_game"] = "6"
        case .zenlessZone:
            let header = "https://api-takumi-record.mihoyo.com/event/game_record_zzz/api/zzz"
            target["x-rpc-challenge_path"] = "\(header)/note"
            target["x-rpc-challenge_game"] = "8"
        }
    }
}
