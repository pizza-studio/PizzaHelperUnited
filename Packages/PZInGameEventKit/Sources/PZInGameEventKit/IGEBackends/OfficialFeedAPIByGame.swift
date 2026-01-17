// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
extension Pizza.SupportedGame {
    public func getOfficialFeedPackageOnline(
        _ server: HoYo.Server,
        lang: HoYo.APILang = Locale.hoyoAPILanguage
    ) async
        -> Result<HoYoEventPack, Error> {
        var server = server
        server.changeGame(to: self)
        do {
            // EventContent
            await HoYo.waitFor300ms()
            let urlDataC = getOfficialEventFeedURL(server, lang: lang, isContent: true)
            let dataC = try await AF.request(urlDataC)
                .validate(statusCode: 200 ... 200).serializingData().value
            let objContent = try HoYoEventPack.HoYoEventContent.decodeFromMiHoYoAPIJSONResult(
                data: dataC,
                debugTag: "getOfficialFeedPackageOnline.dataC"
            )
            // EventMeta
            await HoYo.waitFor300ms()
            let urlDataM = getOfficialEventFeedURL(server, lang: lang, isContent: false)
            let dataM = try await AF.request(urlDataM)
                .validate(statusCode: 200 ... 200).serializingData().value
            let objMeta = try HoYoEventPack.HoYoEventMeta.decodeFromMiHoYoAPIJSONResult(
                data: dataM,
                debugTag: "getOfficialFeedPackageOnline.dataM"
            )
            // Assemble
            return .success(.init(content: objContent, meta: objMeta))
        } catch {
            return .failure(error)
        }
    }

    public func getOfficialEventFeedURL(
        _ server: HoYo.Server,
        lang: HoYo.APILang,
        isContent: Bool
    )
        -> URL {
        var regionRawValue = server.region.rawValue
        var serverRawValue = server.rawValue
        var hoyoBizID = hoyoBizID
        // 临时措施：绝区零目前只有国服有有效新闻源。
        if server.region == .hoyoLab(.zenlessZone) {
            regionRawValue = HoYo.AccountRegion.miyoushe(.zenlessZone).rawValue
            serverRawValue = HoYo.Server.celestia(.zenlessZone).rawValue
            hoyoBizID = "nap" // 確保 game 參數為國服
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
        components.queryItems = [
            .init(name: "game", value: hoyoBizID),
            .init(name: "game_biz", value: regionRawValue),
            .init(name: "lang", value: lang.rawValue),
            .init(name: "bundle_id", value: regionRawValue),
            .init(name: "level", value: "1"),
            .init(name: "platform", value: "pc"),
            .init(name: "region", value: serverRawValue),
            .init(name: "uid", value: "114514"),
        ]
        #if DEBUG
        print("[DEBUG] OfficialFeedAPI URL: \(components.url?.absoluteString ?? "nil")")
        #endif
        return components.url!
    }
}

extension Pizza.SupportedGame {
    public func getBundledTestOfficialFeedPackage() throws -> HoYoEventPack {
        .init(
            content: try .decodeFromMiHoYoAPIJSONResult(
                data: getTestDataForOfficialEvents(isContent: true),
                debugTag: "getTestDataForOfficialFeedPackage()"
            ),
            meta: try .decodeFromMiHoYoAPIJSONResult(
                data: getTestDataForOfficialEvents(isContent: false),
                debugTag: "getTestDataForOfficialFeedPackage()"
            )
        )
    }

    public func getTestDataForOfficialEvents(isContent: Bool) -> Data {
        let shortID = switch self {
        case .genshinImpact: "gi_cn"
        case .starRail: "hsr_cn"
        case .zenlessZone: "zzz_cn"
        }
        let url = Bundle.currentSPM.url(
            forResource: "feeds_" + shortID + (isContent ? "_content" : ""),
            withExtension: "json"
        )!
        return try! Data(contentsOf: url)
    }
}
