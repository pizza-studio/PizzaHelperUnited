// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYo.BattleReport4GI

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct BattleReport4GI: BattleReport {
        // MARK: Lifecycle

        public init(
            spiralAbyss: SpiralAbyssData,
            stygianOnslaught: StygianOnslaughtData? = nil
        ) {
            self.spiralAbyss = spiralAbyss
            self.stygianOnslaught = stygianOnslaught
        }

        // MARK: Public

        public typealias ViewType = BattleReportView4GI

        public var spiralAbyss: SpiralAbyssData
        public var stygianOnslaught: StygianOnslaughtData?
    }
}

// MARK: - HoYo.BattleReport4GI.TreasuresStarwardType

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4GI {
    public enum TreasuresStarwardType: String, Identifiable, CaseIterable, AbleToCodeSendHash {
        case stygianOnslaught
        case spiralAbyss

        // MARK: Public

        public var id: String { rawValue }

        public var localizedTitle: String {
            .init(localized: localizedStringKey, bundle: .currentSPM)
        }

        // MARK: Internal

        var localizedStringKey: String.LocalizationValue {
            switch self {
            case .spiralAbyss:
                .init("hylKit.battleReportView4GI.navTitle.spiralAbyss")
            case .stygianOnslaught:
                .init("hylKit.battleReportView4GI.navTitle.stygianOnslaught")
            }
        }

        var iconFileNameStem: String {
            switch self {
            case .spiralAbyss: "gi_TS_SpiralAbyss"
            case .stygianOnslaught: "gi_TS_StygianOnslaught"
            }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4GI {
    public struct LatestChallengeIntel: AbleToCodeSendHash {
        public let type: TreasuresStarwardType
        public let deepestLevel: String
        public let totalStarsGained: Int
    }

    public var latestChallengeType: TreasuresStarwardType? {
        var mapTimeAndType: [TreasuresStarwardType: Int] = [:]
        // 此处的时区是随便取的，只要三个时区都雷同就行。
        mapTimeAndType[.spiralAbyss] = Int(spiralAbyss.startTime) ?? 0
        mapTimeAndType[.stygianOnslaught] = Int(stygianOnslaught?.schedule.startTime ?? "0") ?? 0
        let possible = mapTimeAndType.max {
            $0.value < $1.value
        }
        return possible?.key
    }

    public var latestChallengeIntel: LatestChallengeIntel? {
        guard let latestChallengeType else { return nil }
        switch latestChallengeType {
        case .spiralAbyss:
            guard spiralAbyss.hasData else { return nil }
            let deepestLevel = spiralAbyss.maxFloorNumStr
            let starNum = spiralAbyss.starNum
            return .init(
                type: latestChallengeType,
                deepestLevel: deepestLevel,
                totalStarsGained: starNum
            )
        case .stygianOnslaught:
            let singleData = stygianOnslaught?.single
            guard let singleData, singleData.hasData else { return nil }
            let deepestLevel = singleData.best?.difficulty.description ?? "0"
            let secondsSpent = singleData.best?.second ?? 114_514
            return .init(
                type: latestChallengeType,
                deepestLevel: deepestLevel,
                totalStarsGained: secondsSpent
            )
        }
    }
}
