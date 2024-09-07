// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

typealias AvatarHoldingReceiveDataFetchModelResult =
    FetchHomeModelResult<AvatarHoldingReceiveData>
typealias TeamUtilizationDataFetchModelResult =
    FetchHomeModelResult<TeamUtilizationData>
typealias UtilizationDataFetchModelResult =
    FetchHomeModelResult<UtilizationData>
typealias AvatarHoldingReceiveDataFetchModel =
    FetchHomeModel<AvatarHoldingReceiveData>

typealias HomeServerVersion = String
typealias HomeServerVersionFetchModel = FetchHomeModel<HomeServerVersion>
typealias HomeServerVersionFetchModelResult = FetchHomeModelResult<HomeServerVersion>
typealias PSAServerPostResultModelResult = FetchHomeModelResult<String?>
typealias UtilizationDataFetchModel = FetchHomeModel<UtilizationData>
typealias TeamUtilizationDataFetchModel = FetchHomeModel<TeamUtilizationData>
typealias AvatarHoldingReceiveData = AvatarPercentageModel
typealias UtilizationData = AvatarPercentageModel

// MARK: - PSAServerError

enum PSAServerError: Error {
    case uploadError(String)
    case getDataError(String)
}

// MARK: - FetchHomeModel

struct FetchHomeModel<T: Codable>: Codable {
    let retCode: Int
    let message: String
    let data: T
}

typealias FetchHomeModelResult<T: Codable> = Result<
    FetchHomeModel<T>,
    PSAServerError
>

// MARK: - AvatarPercentageModel

struct AvatarPercentageModel: Codable {
    struct Avatar: Codable {
        let charId: Int
        let percentage: Double?
    }

    let totalUsers: Int
    let avatars: [Avatar]
}

// MARK: - TeamUtilizationData

struct TeamUtilizationData: Codable {
    struct Team: Codable {
        let team: [Int]
        let percentage: Double
    }

    let totalUsers: Int
    let teams: [Team]
    let teamsFH: [Team]
    let teamsSH: [Team]
}
