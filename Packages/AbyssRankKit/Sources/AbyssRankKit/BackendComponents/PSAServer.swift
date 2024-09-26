// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - PSAServer

@MainActor
enum PSAServer {
    /// 深境螺旋角色使用率
    static func fetchAbyssUtilizationData(
        season: Int? = nil,
        server: HoYo.Server? = nil,
        floor: Int = 12,
        pvp: Bool,
        _ completion: @escaping (UtilizationDataFetchModelResult) -> Void
    ) async {
        // 请求类别
        let urlStr = "/abyss/utilization"

        var paramDict = [String: String]()
        if let season = season {
            paramDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        paramDict.updateValue(String(describing: floor), forKey: "floor")
        if let server = server {
            paramDict.updateValue(server.id, forKey: "server")
        }

        paramDict.updateValue(String(pvp), forKey: "pvp")

        // 请求
        await handleHTTPMethodResults {
            try await HttpMethod<UtilizationDataFetchModel>
                .homeServerRequest(.get, urlStr: urlStr, paramDict: paramDict)
        } completionHandler: { result in
            completion(result)
        }
    }

    /// 满星玩家持有率
    static func fetchFullStarHoldingRateData(
        season: Int? = nil,
        server: HoYo.Server? = nil,
        _ completion: @escaping (AvatarHoldingReceiveDataFetchModelResult)
            -> Void
    ) async {
        // 请求类别
        let urlStr = "/abyss/holding/full_star"

        var paramDict = [String: String]()
        if let season = season {
            paramDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        if let server = server {
            paramDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await handleHTTPMethodResults {
            try await HttpMethod<AvatarHoldingReceiveDataFetchModel>
                .homeServerRequest(.get, urlStr: urlStr, paramDict: paramDict)
        } completionHandler: { result in
            completion(result)
        }
    }

    /// 所有玩家持有率
    static func fetchHoldingRateData(
        queryStartDate: Date? = nil,
        server: HoYo.Server? = nil,
        _ completion: @escaping (AvatarHoldingReceiveDataFetchModelResult)
            -> Void
    ) async {
        // 请求类别
        let urlStr = "/user_holding/holding_rate"

        var paramDict = [String: String]()
        if let queryStartDate = queryStartDate {
            let dateFormatter = DateFormatter.Gregorian()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            paramDict.updateValue(
                String(
                    describing: dateFormatter
                        .string(from: queryStartDate)
                ),
                forKey: "start"
            )
        }
        if let server = server {
            paramDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await handleHTTPMethodResults {
            try await HttpMethod<AvatarHoldingReceiveDataFetchModel>
                .homeServerRequest(.get, urlStr: urlStr, paramDict: paramDict)
        } completionHandler: { result in
            completion(result)
        }
    }

    /// 后台服务器版本
    static func fetchHomeServerVersion(
        _ completion: @escaping (HomeServerVersionFetchModelResult) -> Void
    ) async {
        // 请求类别
        let urlStr = "/debug/version"

        // 请求
        await handleHTTPMethodResults {
            try await HttpMethod<HomeServerVersionFetchModel>
                .homeServerRequest(.get, urlStr: urlStr)
        } completionHandler: { result in
            completion(result)
        }
    }

    /// 深境螺旋角色使用率
    static func fetchTeamUtilizationData(
        season: Int? = nil,
        server: HoYo.Server? = nil,
        floor: Int = 12,
        _ completion: @escaping (TeamUtilizationDataFetchModelResult) -> Void
    ) async {
        // 请求类别
        let urlStr = "/abyss/utilization/teams"

        var paramDict = [String: String]()
        if let season = season {
            paramDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        paramDict.updateValue(String(describing: floor), forKey: "floor")
        if let server = server {
            paramDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await handleHTTPMethodResults {
            try await HttpMethod<TeamUtilizationDataFetchModel>
                .homeServerRequest(.get, urlStr: urlStr, paramDict: paramDict)
        } completionHandler: { result in
            completion(result)
        }
    }
}

extension PSAServer {
    fileprivate static func handleHTTPMethodResults<T>(
        from requestResultGenerator: @escaping () async throws -> FetchHomeModel<T>,
        completionHandler: @escaping (Result<FetchHomeModel<T>, PSAServerError>) -> Void
    ) async {
        do {
            let requestResult = try await requestResultGenerator()
            switch requestResult.retCode {
            case 0: completionHandler(.success(requestResult))
            default: completionHandler(.failure(.getDataError(requestResult.message)))
            }
        } catch {
            completionHandler(.failure(.getDataError("\(error)")))
        }
    }
}
