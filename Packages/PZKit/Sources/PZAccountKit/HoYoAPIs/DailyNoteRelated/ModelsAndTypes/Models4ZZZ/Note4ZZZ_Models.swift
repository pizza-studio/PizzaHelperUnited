// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4ZZZ

public struct Note4ZZZ: Codable, Hashable, DecodableFromMiHoYoAPIJSONResult, DailyNoteProtocol {
    // MARK: Lifecycle

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeysBackup.self)
        self.energy = try container.decode(Energy.self, forKey: .energy)
        self.vitality = try container.decode(Vitality.self, forKey: .vitality)
        self.cardSign = try container.decodeIfPresent(String.self, forKey: .cardSign)
        if let vhsStoreStateDecoded = try container.decodeIfPresent(VHSState.self, forKey: .vhsStoreState) {
            self.vhsStoreState = vhsStoreStateDecoded
        } else if let vhsStateDecoded = try container.decodeIfPresent(VHSSale.self, forKey: .vhsSale) {
            self.vhsStoreState = vhsStateDecoded.saleState
        } else {
            self.vhsStoreState = .awaitingForOperation
        }
        if let hollowZeroDecoded = try container.decodeIfPresent(HollowZero.self, forKey: .hollowZero) {
            self.hollowZero = hollowZeroDecoded
        } else {
            let subContainer = try decoder.container(keyedBy: HollowZero.CodingKeys.self)
            self.hollowZero = .init(
                bountyCommission: try subContainer.decodeIfPresent(
                    HollowZero.BountyCommission.self,
                    forKey: HollowZero.CodingKeys.bountyCommission
                ),
                investigationPoint: try subContainer.decodeIfPresent(
                    HollowZero.InvestigationPointIntel.self,
                    forKey: HollowZero.CodingKeys.investigationPoint
                )
            )
        }
    }

    // MARK: Public

    public static let game: Pizza.SupportedGame = .zenlessZone

    /// 电池电量
    public let energy: Energy
    public let vitality: Vitality
    public let vhsStoreState: VHSState
    public let hollowZero: HollowZero

    public var cardScratched: Bool? {
        cardSign?.contains("Done")
    }

    // MARK: Internal

    enum CodingKeysBackup: String, CodingKey {
        case energy
        case vitality
        case cardSign = "card_sign"
        case hollowZero = "hollow_zero"
        case vhsStoreState = "video_store_state"
        case vhsSale = "vhs_sale" // Only for decoding.
    }

    // MARK: Private

    private let cardSign: String?
}

extension Note4ZZZ {
    public struct HollowZero: AbleToCodeSendHash {
        // MARK: Public

        public let bountyCommission: BountyCommission?
        public let investigationPoint: InvestigationPointIntel?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case bountyCommission = "bounty_commission"
            case investigationPoint = "survey_points"
        }
    }

    // MARK: - Vitality

    public struct Vitality: AbleToCodeSendHash {
        // MARK: Lifecycle

        init(max: Int, current: Int) {
            self.max = max
            self.current = current
        }

        // MARK: Public

        public let max: Int
        public let current: Int

        public var textDescription: String { "\(current) / \(max)" }
        public var accomplished: Bool { max == current }
    }

    // MARK: - VHSSale

    private struct VHSSale: AbleToCodeSendHash {
        // MARK: Public

        public let saleState: VHSState

        public var isInOperation: Bool {
            saleState == .inOperation
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case saleState = "sale_state"
        }
    }

    public enum VHSState: String, AbleToCodeSendHash {
        case revenueAvailable = "SaleStateDone"
        case awaitingForOperation = "SaleStateNo"
        case inOperation = "SaleStateDoing"

        // MARK: Public

        public var localizedDescription: String {
            switch self {
            case .revenueAvailable:
                String(localized: "dailyNote.zzz.vhsState.revenueAvailable", bundle: .module)
            case .awaitingForOperation:
                String(localized: "dailyNote.zzz.vhsState.awaitingForOperation", bundle: .module)
            case .inOperation:
                String(localized: "dailyNote.zzz.vhsState.inOperation", bundle: .module)
            }
        }

        public var isInOperation: Bool {
            self == .inOperation
        }
    }

    // MARK: - Energy

    public struct Energy: AbleToCodeSendHash {
        // MARK: Lifecycle

        init(progress: EnergyProgress, restore: Int) {
            self.progress = EnergyProgress(max: progress.max, current: progress.current)
            self.restore = restore
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: Note4ZZZ.Energy.CodingKeys.self)

            self.progress = try container.decode(EnergyProgress.self, forKey: .progress)
            self.restore = try container.decode(Int.self, forKey: .restore)
        }

        // MARK: Public

        public struct EnergyProgress: AbleToCodeSendHash {
            public let max: Int
            public let current: Int

            public var percent: Int {
                Int(Double(current) / Double(max) * 100)
            }
        }

        public let progress: EnergyProgress
        public let restore: Int
        public let fetchedTime: Date = .now // 从伺服器拿到这笔资料的那一刻的时间戳。

        public var fullyChargedDate: Date {
            .init(timeInterval: Double(restore), since: fetchedTime)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Note4ZZZ.Energy.CodingKeys.self)
            try container.encode(progress, forKey: .progress)
            try container.encode(restore, forKey: .restore)
            try container.encode(fetchedTime, forKey: .fetchedTime)
        }

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case progress
            case restore
            case fetchedTime
        }
    }
}

extension Note4ZZZ.HollowZero {
    // MARK: - BountyCommission

    public struct BountyCommission: AbleToCodeSendHash {
        public let num: Int
        public let total: Int

        public var textDescription: String { "\(num) / \(total)" }
    }

    // MARK: - SurveyPoints

    public struct InvestigationPointIntel: AbleToCodeSendHash {
        // MARK: Public

        public let num: Int
        public let total: Int
        public let isMaxLevel: Bool

        public var textDescription: String { "\(num) / \(total)" }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case num
            case total
            case isMaxLevel = "is_max_level"
        }
    }
}

extension Note4ZZZ.Energy {
    // MARK: Public

    /// Each primary stamina needs 6 minutes to recover
    public static let eachStaminaRecoveryTime: TimeInterval = 60 * 6

    /// Each backup stamina needs 6 minutes to recover
    public static let eachBackupStaminaRecoveryTime: TimeInterval = 60 * 18

    public var currentEnergyAmountDynamic: Int {
        let baseValue = progress.current
        let timePassedSinceLastFetch = Date.now.timeIntervalSince1970 - fetchedTime.timeIntervalSince1970
        return baseValue + Int((timePassedSinceLastFetch / Self.eachStaminaRecoveryTime).rounded(.down))
    }

    public var timeOnFinish: Date {
        guard progress.current < progress.max else { return .now }
        let restEnergyToCharge = progress.max - currentEnergyAmountDynamic
        let timeIntervalDelta = Self.eachStaminaRecoveryTime * Double(restEnergyToCharge)
        return Date.now.addingTimeInterval(timeIntervalDelta)
    }
}

// MARK: - Example

extension Note4ZZZ {
    public static func exampleData() -> Note4ZZZ {
        let exampleURL = Bundle.module.url(
            forResource: "zzz_realtime_note_example_miyoushe", withExtension: "json"
        )!
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! Note4ZZZ.decodeFromMiHoYoAPIJSONResult(
            data: exampleData, debugTag: "Note4ZZZ.exampleData()"
        )
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }
}
