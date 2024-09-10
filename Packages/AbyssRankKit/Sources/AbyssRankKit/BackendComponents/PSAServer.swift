// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

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

        var paraDict = [String: String]()
        if let season = season {
            paraDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        paraDict.updateValue(String(describing: floor), forKey: "floor")
        if let server = server {
            paraDict.updateValue(server.id, forKey: "server")
        }

        paraDict.updateValue(String(pvp), forKey: "pvp")

        // 请求
        await HttpMethod<UtilizationDataFetchModel>
            .homeServerRequest(
                .get,
                urlStr: urlStr,
                parasDict: paraDict
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
//                        let userData = requestResult.data
//                        let retcode = requestResult.retCode
//                        let message = requestResult.message

                    switch requestResult.retCode {
                    case 0:
                        print("get data succeed")
                        completion(.success(requestResult))
                    default:
                        print("fail")
                        completion(.failure(.getDataError(
                            requestResult
                                .message
                        )))
                    }

                case let .failure(error):
                    completion(.failure(.getDataError(
                        error
                            .localizedDescription
                    )))
                }
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

        var paraDict = [String: String]()
        if let season = season {
            paraDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        if let server = server {
            paraDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await HttpMethod<AvatarHoldingReceiveDataFetchModel>
            .homeServerRequest(
                .get,
                urlStr: urlStr,
                parasDict: paraDict
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
//                        let userData = requestResult.data
//                        let retcode = requestResult.retCode
//                        let message = requestResult.message

                    switch requestResult.retCode {
                    case 0:
                        print("get data succeed")
                        completion(.success(requestResult))
                    default:
                        print("fail")
                        completion(.failure(.getDataError(
                            requestResult
                                .message
                        )))
                    }

                case let .failure(error):
                    completion(.failure(.getDataError(
                        error
                            .localizedDescription
                    )))
                }
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

        var paraDict = [String: String]()
        if let queryStartDate = queryStartDate {
            let dateFormatter = DateFormatter.Gregorian()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            paraDict.updateValue(
                String(
                    describing: dateFormatter
                        .string(from: queryStartDate)
                ),
                forKey: "start"
            )
        }
        if let server = server {
            paraDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await HttpMethod<AvatarHoldingReceiveDataFetchModel>
            .homeServerRequest(
                .get,
                urlStr: urlStr,
                parasDict: paraDict
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
//                        let userData = requestResult.data
//                        let retcode = requestResult.retCode
//                        let message = requestResult.message

                    switch requestResult.retCode {
                    case 0:
                        print("get data succeed")
                        completion(.success(requestResult))
                    default:
                        print("fail")
                        completion(.failure(.getDataError(
                            requestResult
                                .message
                        )))
                    }

                case let .failure(error):
                    completion(.failure(.getDataError(
                        error
                            .localizedDescription
                    )))
                }
            }
    }

    /// 后台服务器版本
    static func fetchHomeServerVersion(
        _ completion: @escaping (HomeServerVersionFetchModelResult) -> Void
    ) async {
        // 请求类别
        let urlStr = "/debug/version"

        // 请求
        await HttpMethod<HomeServerVersionFetchModel>
            .homeServerRequest(
                .get,
                urlStr: urlStr
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
//                        let userData = requestResult.data
//                        let retcode = requestResult.retCode
//                        let message = requestResult.message

                    switch requestResult.retCode {
                    case 0:
                        print("get data succeed")
                        completion(.success(requestResult))
                    default:
                        print("fail")
                        completion(.failure(.getDataError(
                            requestResult
                                .message
                        )))
                    }

                case let .failure(error):
                    completion(.failure(.getDataError(
                        error
                            .localizedDescription
                    )))
                }
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

        var paraDict = [String: String]()
        if let season = season {
            paraDict.updateValue(
                String(describing: season),
                forKey: "season"
            )
        }

        paraDict.updateValue(String(describing: floor), forKey: "floor")
        if let server = server {
            paraDict.updateValue(server.id, forKey: "server")
        }

        // 请求
        await HttpMethod<TeamUtilizationDataFetchModel>
            .homeServerRequest(
                .get,
                urlStr: urlStr,
                parasDict: paraDict
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
//                        let userData = requestResult.data
//                        let retcode = requestResult.retCode
//                        let message = requestResult.message

                    switch requestResult.retCode {
                    case 0:
                        print("get data succeed")
                        completion(.success(requestResult))
                    default:
                        print("fail")
                        completion(.failure(.getDataError(
                            requestResult
                                .message
                        )))
                    }

                case let .failure(error):
                    completion(.failure(.getDataError(
                        error
                            .localizedDescription
                    )))
                }
            }
    }
}
