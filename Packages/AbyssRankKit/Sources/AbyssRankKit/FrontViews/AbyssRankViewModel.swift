// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssRankViewModel

@Observable @MainActor
class AbyssRankViewModel {
    // MARK: Lifecycle

    init() {
        self.showingType = .abyssAvatarsUtilization
    }

    // MARK: Internal

    enum ShowingData: String, CaseIterable, Identifiable, Equatable {
        case abyssAvatarsUtilization = "abyssRankKit.rank.usageRate.characters"
        case pvpUtilization = "abyssRankKit.rank.usageRate.characterSansRestart"
        case teamUtilization = "abyssRankKit.rank.usageRate.teams"
        case fullStarHoldingRate = "abyssRankKit.rank.holdingRate.36star"
        case holdingRate = "abyssRankKit.rank.holdingRate.all"

        // MARK: Internal

        var id: String { rawValue }
    }

    // MARK: - 所有用户持有率

    var avatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?

    // MARK: - 满星用户持有率

    var fullStarAvatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?

    // MARK: - 深境螺旋使用率

    var utilizationDataFetchModelResult: UtilizationDataFetchModelResult?

    // MARK: - 深境螺旋队伍使用率

    var teamUtilizationDataFetchModelResult: TeamUtilizationDataFetchModelResult?

    // MARK: - 未重开使用率

    var pvpUtilizationDataFetchModelResult: UtilizationDataFetchModelResult?

    var showingType: ShowingData

    var holdingParam: AvatarHoldingAPIParameters = .init()

    var fullStarHoldingParam: FullStarAPIParameters = .init()

    var utilizationParams: UtilizationAPIParameters = .init()

    var teamUtilizationParams: TeamUtilizationAPIParameters =
        .init()

    var pvpUtilizationParams: UtilizationAPIParameters = .init()

    var initialized: Bool = false

    var paramsDescription: String {
        let result: String = { switch showingType {
        case .fullStarHoldingRate:
            return fullStarHoldingParam.describe()
        case .holdingRate:
            return holdingParam.describe()
        case .abyssAvatarsUtilization, .pvpUtilization:
            return utilizationParams.describe()
        case .teamUtilization:
            return teamUtilizationParams.describe()
        }
        }()
        return result.replacingOccurrences(of: "·", with: "\n")
    }

    var totalDataCount: Int {
        switch showingType {
        case .fullStarHoldingRate:
            return (try? fullStarAvatarHoldingResult?.get().data.totalUsers) ?? 0
        case .holdingRate:
            return (try? avatarHoldingResult?.get().data.totalUsers) ?? 0
        case .abyssAvatarsUtilization:
            return (
                try? utilizationDataFetchModelResult?.get().data
                    .totalUsers
            ) ?? 0
        case .teamUtilization:
            return (
                try? teamUtilizationDataFetchModelResult?.get().data
                    .totalUsers
            ) ?? 0
        case .pvpUtilization:
            return (
                try? pvpUtilizationDataFetchModelResult?.get().data
                    .totalUsers
            ) ?? 0
        }
    }

    var paramsDetailDescription: String {
        switch showingType {
        case .fullStarHoldingRate:
            return fullStarHoldingParam.detail()
        case .holdingRate:
            return holdingParam.detail()
        case .abyssAvatarsUtilization:
            return utilizationParams.detail()
        case .teamUtilization:
            return teamUtilizationParams.detail()
        case .pvpUtilization:
            return pvpUtilizationParams.detail()
        }
    }

    func getData() async {
        switch showingType {
        case .abyssAvatarsUtilization:
            await getUtilizationResult()
        case .holdingRate:
            await getAvatarHoldingResult()
        case .fullStarHoldingRate:
            await getFullStarHoldingResult()
        case .teamUtilization:
            await getTeamUtilizationResult()
        case .pvpUtilization:
            await getPVPUtilizationResult()
        }
    }

    func getAvatarHoldingResult() async {
        let holdingParam = holdingParam
        await PSAServer.fetchHoldingRateData(
            queryStartDate: holdingParam.date,
            server: holdingParam.server
        ) { result in
            withAnimation {
                self.avatarHoldingResult = result
            }
        }
    }

    func getFullStarHoldingResult() async {
        let fullStarHoldingParam = fullStarHoldingParam
        await PSAServer.fetchFullStarHoldingRateData(
            season: fullStarHoldingParam.season,
            server: fullStarHoldingParam.server
        ) { result in
            withAnimation {
                self.fullStarAvatarHoldingResult = result
            }
        }
    }

    func getUtilizationResult() async {
        let utilizationParams = utilizationParams
        await PSAServer.fetchAbyssUtilizationData(
            season: utilizationParams.season,
            server: utilizationParams.server,
            floor: utilizationParams.floor,
            pvp: false
        ) { result in
            withAnimation {
                self.utilizationDataFetchModelResult = result
            }
        }
    }

    func getTeamUtilizationResult() async {
        await PSAServer.fetchTeamUtilizationData(
            season: teamUtilizationParams.season,
            server: teamUtilizationParams.server,
            floor: teamUtilizationParams.floor
        ) { result in
            self.teamUtilizationDataFetchModelResult = result
        }
    }

    func getPVPUtilizationResult() async {
        await PSAServer.fetchAbyssUtilizationData(
            season: utilizationParams.season,
            server: utilizationParams.server,
            floor: utilizationParams.floor,
            pvp: true
        ) { result in
            withAnimation {
                self.pvpUtilizationDataFetchModelResult = result
            }
        }
    }
}
