// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYo.BattleReport4GI

extension HoYo {
    public struct BattleReport4GI: BattleReport {
        // MARK: Lifecycle

        public init(
            spiralAbyss: SpiralAbyssData,
        ) {
            self.spiralAbyss = spiralAbyss
        }

        // MARK: Public

        public typealias ViewType = BattleReportView4GI

        public var spiralAbyss: SpiralAbyssData
    }
}

// MARK: - HoYo.BattleReport4GI.TreasuresStarwardType

extension HoYo.BattleReport4GI {
    public enum TreasuresStarwardType: String, Identifiable, CaseIterable, AbleToCodeSendHash {
        case spiralAbyss

        // MARK: Public

        public var id: String { rawValue }

        public var localizedTitle: String {
            .init(localized: localizedStringKey, bundle: .module)
        }

        // MARK: Internal

        var localizedStringKey: String.LocalizationValue {
            switch self {
            case .spiralAbyss:
                .init("hylKit.battleReportView4GI.navTitle.spiralAbyss")
            }
        }

        var iconFileNameStem: String {
            switch self {
            case .spiralAbyss: "gi_TS_SpiralAbyss"
            }
        }
    }
}

extension HoYo.BattleReport4GI {
    public struct LatestChallengeIntel: AbleToCodeSendHash {
        public let type: TreasuresStarwardType
        public let deepestLevel: String
        public let totalStarsGained: Int
    }

    public var latestChallengeType: TreasuresStarwardType? {
        .spiralAbyss
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
        }
    }
}
