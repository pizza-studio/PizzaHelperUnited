// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

extension HoYo {
    public static func getLedgerData(for profile: PZProfileMO) async throws -> (any Ledger)? {
        switch profile.game {
        case .genshinImpact:
            guard let month = Calendar.current.dateComponents([.month], from: Date()).month else { return nil }
            return try await getLedgerData4GI(
                month: month,
                uid: profile.uid,
                server: profile.server,
                cookie: profile.cookie
            )
        case .starRail:
            let components = Calendar.current.dateComponents([.year, .month], from: Date.now)
            guard let year = components.year?.description else { return nil }
            guard var month = components.month?.description else { return nil }
            if month.count == 1 {
                month.insert("0", at: month.startIndex)
            }
            return try await getLedgerData4HSR(
                month: year + month,
                uid: profile.uid,
                server: profile.server,
                cookie: profile.cookie
            )
        case .zenlessZone: return nil
        }
    }

    public static func getLedgerData4GI(
        month: Int, uid: String, server: Server, cookie: String
    ) async throws
        -> LedgerData4GI {
        #if DEBUG
        print("||| START REQUESTING LEDGER DATA (GI) |||")
        #endif
        let cookie = try await { () -> String in
            guard case .miyoushe = server.region else { return cookie }
            let cookieToken = try await cookieToken(game: .genshinImpact, cookie: cookie)
            return "cookie_token=\(cookieToken.cookieToken); account_id=\(cookieToken.uid);"
        }()
        let queryItems: [URLQueryItem] = switch server.region {
        case .miyoushe:
            [
                .init(name: "month", value: "\(month)"),
                .init(name: "bind_uid", value: "\(uid)"),
                .init(name: "bind_region", value: server.rawValue),
                .init(name: "bbs_presentation_style", value: "fullscreen"),
                .init(name: "bbs_auth_required", value: "true"),
                .init(name: "utm_source", value: "bbs"),
                .init(name: "utm_medium", value: "mys"),
                .init(name: "utm_compaign", value: "icon"),
            ]
        case .hoyoLab:
            [
                .init(name: "month", value: String(month)),
                .init(name: "region", value: server.rawValue),
                .init(name: "uid", value: String(uid)),
                .init(name: "lang", value: Locale.hoyoAPILanguage.rawValue),
            ]
        }

        let request = try await generateRequest(
            httpMethod: .get,
            region: server.region,
            host: URLRequestConfig.ledgerAPIURLHost(region: server.region),
            path: server.region.ledgerDataRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        #if DEBUG
        print("---------------------------------------------")
        print(request.debugDescription)
        if let headerEX = request.allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try! encoder.encode(headerEX), encoding: .utf8)!)
        }
        print("---------------------------------------------")
        #endif

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }

    public static func getLedgerData4HSR(
        month: String, uid: String, server: Server, cookie: String
    ) async throws
        -> LedgerData4HSR {
        #if DEBUG
        print("||| START REQUESTING LEDGER DATA (HSR) |||")
        #endif
        let cookie = try await { () -> String in
            guard case .miyoushe = server.region else { return cookie }
            let cookieToken = try await cookieToken(game: .genshinImpact, cookie: cookie)
            return "cookie_token=\(cookieToken.cookieToken); account_id=\(cookieToken.uid);"
        }()
        let queryItems: [URLQueryItem] = switch server.region {
        case .miyoushe:
            [
                .init(name: "lang", value: Locale.hoyoAPILanguage.rawValue),
                .init(name: "region", value: server.rawValue),
                .init(name: "uid", value: String(uid)),
                .init(name: "month", value: month),
            ]
        case .hoyoLab:
            [
                .init(name: "lang", value: Locale.hoyoAPILanguage.rawValue),
                .init(name: "region", value: server.rawValue),
                .init(name: "uid", value: String(uid)),
                .init(name: "month", value: month),
            ]
        }

        let request = try await generateRequest(
            httpMethod: .get,
            region: server.region,
            host: URLRequestConfig.ledgerAPIURLHost(region: server.region),
            path: server.region.ledgerDataRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: nil
        )
        #if DEBUG
        print("---------------------------------------------")
        print(request.debugDescription)
        if let headerEX = request.allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try! encoder.encode(headerEX), encoding: .utf8)!)
        }
        print("---------------------------------------------")
        #endif

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}

extension HoYo.AccountRegion {
    public var ledgerDataRetrievalPath: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "/event/ysledgeros/month_info"
        case (.miyoushe, .genshinImpact): "/event/ys_ledger/monthInfo"
        case (.hoyoLab, .starRail): "/event/srledger/month_info"
        case (.miyoushe, .starRail): "/event/srledger/month_info"
        default: "" // 尚无该功能可用。
        }
    }
}
