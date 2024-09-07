// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssRankViewModel

@Observable
class AbyssRankViewModel {
    // MARK: Lifecycle

    init() {
        self.showingType = .abyssAvatarsUtilization
        getData()
    }

    // MARK: Internal

    enum ShowingData: String, CaseIterable, Identifiable {
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

    var fullStaAvatarHoldingResult: AvatarHoldingReceiveDataFetchModelResult?

    // MARK: - 深境螺旋使用率

    var utilizationDataFetchModelResult: UtilizationDataFetchModelResult?

    // MARK: - 深境螺旋队伍使用率

    var teamUtilizationDataFetchModelResult: TeamUtilizationDataFetchModelResult?

    // MARK: - 未重开使用率

    var pvpUtilizationDataFetchModelResult: UtilizationDataFetchModelResult?

    var showingType: ShowingData {
        didSet {
            getData()
        }
    }

    var holdingParam: AvatarHoldingAPIParameters = .init() {
        didSet { getAvatarHoldingResult() }
    }

    var fullStarHoldingParam: FullStarAPIParameters = .init() {
        didSet { getFullStarHoldingResult() }
    }

    var utilizationParams: UtilizationAPIParameters = .init() {
        didSet { getUtilizationResult() }
    }

    var teamUtilizationParams: TeamUtilizationAPIParameters =
        .init() {
        didSet { getTeamUtilizationResult() }
    }

    var pvpUtilizationParams: UtilizationAPIParameters = .init() {
        didSet { getPVPUtilizationResult() }
    }

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
            return (try? fullStaAvatarHoldingResult?.get().data.totalUsers) ?? 0
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

    func getData() {
        switch showingType {
        case .abyssAvatarsUtilization:
            getUtilizationResult()
        case .holdingRate:
            getAvatarHoldingResult()
        case .fullStarHoldingRate:
            getFullStarHoldingResult()
        case .teamUtilization:
            getTeamUtilizationResult()
        case .pvpUtilization:
            getPVPUtilizationResult()
        }
    }

    func getAvatarHoldingResult() {
        PSAServer.fetchHoldingRateData(
            queryStartDate: holdingParam.date,
            server: holdingParam.server
        ) { result in
            withAnimation {
                self.avatarHoldingResult = result
            }
        }
    }

    func getFullStarHoldingResult() {
        PSAServer.fetchFullStarHoldingRateData(
            season: fullStarHoldingParam.season,
            server: fullStarHoldingParam.server
        ) { result in
            withAnimation {
                self.fullStaAvatarHoldingResult = result
            }
        }
    }

    func getUtilizationResult() {
        PSAServer.fetchAbyssUtilizationData(
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

    func getTeamUtilizationResult() {
        PSAServer.fetchTeamUtilizationData(
            season: teamUtilizationParams.season,
            server: teamUtilizationParams.server,
            floor: teamUtilizationParams.floor
        ) { result in
            self.teamUtilizationDataFetchModelResult = result
        }
    }

    func getPVPUtilizationResult() {
        PSAServer.fetchAbyssUtilizationData(
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
