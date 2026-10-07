// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYo.BattleReport4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct BattleReport4HSR: BattleReport {
        // MARK: Lifecycle

        public init(
            forgottenHall: ForgottenHallData,
            pureFiction: PureFictionData,
            apocalypticShadow: ApocalypticShadowData
        ) {
            self.forgottenHall = forgottenHall
            self.pureFiction = pureFiction
            self.apocalypticShadow = apocalypticShadow
        }

        // MARK: Public

        public typealias DataType = TreasuresLightwardType

        public typealias ViewType = BattleReportView4HSR

        public var forgottenHall: ForgottenHallData
        public let pureFiction: PureFictionData
        public let apocalypticShadow: ApocalypticShadowData
    }
}

// MARK: - HoYo.BattleReport4HSR.TreasuresLightwardType

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4HSR {
    public enum TreasuresLightwardType: String, Identifiable, CaseIterable, AbleToCodeSendHash, HoYoBattleReportType {
        case forgottenHall
        case pureFiction
        case apocalypticShadow

        // MARK: Public

        public typealias BattleReportData = HoYo.BattleReport4HSR

        public var id: String { rawValue }

        public var localizedTitle: String {
            .init(localized: localizedStringKey, bundle: .currentSPM)
        }

        // MARK: Internal

        var localizedStringKey: String.LocalizationValue {
            switch self {
            case .forgottenHall:
                .init("hylKit.battleReportView4HSR.navTitle.forgottenHall")
            case .pureFiction:
                .init("hylKit.battleReportView4HSR.navTitle.pureFiction")
            case .apocalypticShadow:
                .init("hylKit.battleReportView4HSR.navTitle.apocalypticShadow")
            }
        }

        var iconFileNameStem: String {
            switch self {
            case .forgottenHall: "hsr_TL_ForgottenHall"
            case .pureFiction: "hsr_TL_PureFiction"
            case .apocalypticShadow: "hsr_TL_ApocalypticShadow"
            }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4HSR {
    public struct LatestChallengeIntel: AbleToCodeSendHash {
        public let type: TreasuresLightwardType
        public let deepestLevel: String
        public let totalStarsGained: Int
    }

    public var latestChallengeType: TreasuresLightwardType? {
        var mapTimeAndType: [TreasuresLightwardType: Date] = [:]
        // 此处的时区是随便取的，只要三个时区都雷同就行。
        mapTimeAndType[.forgottenHall] = forgottenHall.allNodes.compactMap {
            $0.challengeTime?.asDate(timeZoneDelta: 8)
        }.max()
        mapTimeAndType[.pureFiction] = pureFiction.allNodes.compactMap {
            $0.challengeTime?.asDate(timeZoneDelta: 8)
        }.max()
        mapTimeAndType[.apocalypticShadow] = apocalypticShadow.allNodes.compactMap {
            $0.challengeTime?.asDate(timeZoneDelta: 8)
        }.max()
        let possible = mapTimeAndType.max {
            $0.value.timeIntervalSince1970 < $1.value.timeIntervalSince1970
        }
        return possible?.key
    }

    public var latestChallengeIntel: LatestChallengeIntel? {
        guard let latestChallengeType else { return nil }
        switch latestChallengeType {
        case .forgottenHall:
            guard forgottenHall.hasData else { return nil }
            let deepestLevel = forgottenHall.maxFloorNumStr
            let starNum = forgottenHall.starNum
            return .init(
                type: latestChallengeType,
                deepestLevel: deepestLevel,
                totalStarsGained: starNum
            )
        case .pureFiction:
            guard pureFiction.hasData else { return nil }
            let deepestLevel = pureFiction.maxFloorNumStr
            let starNum = pureFiction.starNum
            return .init(
                type: latestChallengeType,
                deepestLevel: deepestLevel,
                totalStarsGained: starNum
            )
        case .apocalypticShadow:
            guard apocalypticShadow.hasData else { return nil }
            let deepestLevel = apocalypticShadow.maxFloorNumStr
            let starNum = apocalypticShadow.starNum
            return .init(
                type: latestChallengeType,
                deepestLevel: deepestLevel,
                totalStarsGained: starNum
            )
        }
    }
}

// MARK: - HSRFloorDetail

/// 鐵道戰報的樓層詳情共通介面。這三種戰報的樓層結構一致，
/// 差別只在於星數的型別（FH/PF 為 Int，AS 為 String）。
@available(iOS 17.0, macCatalyst 17.0, *)
protocol HSRFloorDetail {
    /// 樓層識別碼。同一層樓重複挑戰時會出現多筆相同 `mazeID` 的紀錄。
    var mazeID: Int { get }
    /// 該筆紀錄的星數。
    var starNumInt: Int { get }
    /// 該筆紀錄的所有節點（已剔除 null 節點）。
    var allNodes: [HoYo.BattleReport4HSR.FHNode] { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HSRFloorDetail {
    /// 該筆紀錄中最後一次挑戰的時間。
    var latestChallengeTime: HoYo.BattleReport4HSR.FHDateComponents? {
        allNodes.compactMap(\.challengeTime).max {
            ($0.asDate(timeZoneDelta: 8) ?? .distantPast) < ($1.asDate(timeZoneDelta: 8) ?? .distantPast)
        }
    }

    var latestChallengeDate: Date? {
        latestChallengeTime?.asDate(timeZoneDelta: 8)
    }

    /// 判斷 `self` 是否比 `other` 更值得顯示：星數優先，其次比時間新。
    func isBetterAttempt(than other: Self) -> Bool {
        if starNumInt != other.starNumInt { return starNumInt > other.starNumInt }
        switch (latestChallengeDate, other.latestChallengeDate) {
        case let (lhs?, rhs?): return lhs > rhs
        case (.some, .none): return true
        case (.none, .none), (.none, .some): return false
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Array where Element: HSRFloorDetail {
    /// 每層樓只保留「星數最高、時間最新」的那次嘗試，並維持原本的樓層順序。
    var bestAttemptsPerFloor: Self {
        var order: [Int] = []
        var best: [Int: Element] = [:]
        for element in self {
            guard let existing = best[element.mazeID] else {
                best[element.mazeID] = element
                order.append(element.mazeID)
                continue
            }
            if element.isBetterAttempt(than: existing) {
                best[element.mazeID] = element
            }
        }
        return order.compactMap { best[$0] }
    }
}
