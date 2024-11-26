// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4ZZZ

public struct Note4ZZZ: Codable, Hashable, DecodableFromMiHoYoAPIJSONResult, DailyNoteProtocol {
    // MARK: Public

    public static let game: Pizza.SupportedGame = .zenlessZone

    /// 电池电量
    public var energy: Energy
    public var vitality: Vitality
    public var vhsSale: VHSSale
    public var cardSign: String?

    public var cardScratched: Bool {
        cardSign?.contains("Done") ?? false
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case energy
        case vitality
        case vhsSale = "vhs_sale"
        case cardSign = "card_sign"
    }
}

extension Note4ZZZ {
    // MARK: - Vitality

    public struct Vitality: AbleToCodeSendHash {
        // MARK: Lifecycle

        init(max: Int, current: Int) {
            self.max = max
            self.current = current
        }

        // MARK: Public

        public var max: Int
        public var current: Int

        public var accomplished: Bool {
            max == current
        }
    }

    // MARK: - VHSSale

    public struct VHSSale: AbleToCodeSendHash {
        // MARK: Public

        public var saleState: String

        public var isInOperation: Bool {
            saleState.contains("Doing")
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case saleState = "sale_state"
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
            public var max: Int
            public var current: Int

            public var percent: Int {
                Int(Double(current) / Double(max) * 100)
            }
        }

        public var progress: EnergyProgress
        public var restore: Int
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
