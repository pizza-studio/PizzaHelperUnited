// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension Pizza.SupportedGame {
    public func getOfficialEventFeedURL(
        _ server: HoYo.Server,
        lang: HoYo.APILang,
        isContent: Bool
    )
        -> URL {
        var regionRawValue = server.region.rawValue
        // 临时措施：绝区零目前只有国服有有效新闻源。
        if server.region == .hoyoLab(.zenlessZone) {
            regionRawValue = HoYo.AccountRegion.miyoushe(.zenlessZone).rawValue
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = switch server.region {
        case .hoyoLab(.genshinImpact): "sg-hk4e-api.hoyoverse.com"
        case .hoyoLab(.starRail): "sg-hkrpg-api.hoyoverse.com"
        case .miyoushe(.genshinImpact): "hk4e-api.mihoyo.com"
        case .miyoushe(.starRail): "hkrpg-api.mihoyo.com"
        case .hoyoLab(.zenlessZone), .miyoushe(.zenlessZone): "announcement-api.mihoyo.com"
        }
        components.path = "/common/\(regionRawValue)/announcement/api"
        components.path += isContent ? "/getAnnContent" : "/getAnnList"
        components.path += "?game=\(hoyoBizID)"
        components.path += "&game_biz=\(regionRawValue)"
        components.path += "&lang=\(lang.rawValue)"
        components.path += "&bundle_id=\(regionRawValue)"
        components.path += "&level=1"
        components.path += "&platform=pc"
        components.path += "&region=\(server.rawValue)"
        components.path += "&uid=114514"
        return components.url!
    }
}

extension Pizza.SupportedGame {
    public func getTestDataForOfficialEvents(isContent: Bool) -> Data {
        let shortID = switch self {
        case .genshinImpact: "gi_cn"
        case .starRail: "hsr_cn"
        case .zenlessZone: "zzz_cn"
        }
        let url = Bundle.module.url(
            forResource: "feeds_" + shortID + (isContent ? "_content" : ""),
            withExtension: "json"
        )!
        return try! Data(contentsOf: url)
    }
}
