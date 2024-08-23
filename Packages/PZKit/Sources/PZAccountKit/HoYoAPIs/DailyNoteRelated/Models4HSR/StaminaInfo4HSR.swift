// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - StaminaInfo4HSR

public struct StaminaInfo4HSR {
    // MARK: Public

    /// Each primary stamina needs 6 minutes to recover
    public static let eachStaminaRecoveryTime: TimeInterval = 60 * 6

    /// Each backup stamina needs 6 minutes to recover
    public static let eachBackupStaminaRecoveryTime: TimeInterval = 60 * 18

    /// Max stamina (Primary).
    public let maxStamina: Int

    /// Current stamina (Primary)
    public var currentStamina: Int {
        maxStamina - restOfStamina
    }

    // Is Primiary Stamina Full.
    public var isPrimaryStaminaFull: Bool {
        restOfStamina == 0 || currentStamina >= maxStamina
    }

    /// Rest of recovery time
    public var remainingTime: TimeInterval {
        let restOfTime = _staminaRecoverTime - benchmarkTime.timeIntervalSince(fetchTime)
        if restOfTime > 0 {
            return restOfTime
        } else {
            return 0
        }
    }

    /// The time when stamina is full
    public var fullTime: Date {
        Date(timeInterval: _staminaRecoverTime, since: fetchTime)
    }

    /// The time when next stamina recover. If the stamina is full, return `nil`
    public var nextStaminaTime: Date? {
        let nextRecoverTimeInterval = remainingTime.truncatingRemainder(dividingBy: Self.eachStaminaRecoveryTime)
        if nextRecoverTimeInterval != 0 {
            return Date(timeInterval: nextRecoverTimeInterval + 1, since: benchmarkTime)
        } else {
            return nil
        }
    }

    public let isReserveStaminaFull: Bool

    // MARK: Private

    /// Reserved Stamina when data is fetched.
    private let _currentReserveStamina: Int
    /// Stamina when data is fetched.
    private let _currentStamina: Int
    /// Recovery time interval when data is fetched.
    private let _staminaRecoverTime: TimeInterval

    /// The time this struct generated
    private let fetchTime: Date = .init()

    private var restOfStamina: Int {
        Int(ceil(remainingTime / Self.eachStaminaRecoveryTime))
    }

    @BenchmarkTime public var benchmarkTime: Date
}

// MARK: Decodable

extension StaminaInfo4HSR: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxStamina = try container.decode(Int.self, forKey: .maxStamina)
        self._currentStamina = try container.decode(Int.self, forKey: .currentStamina)
        self._staminaRecoverTime = try TimeInterval(container.decode(Int.self, forKey: .staminaRecoverTime))
        self._currentReserveStamina = (try? container.decode(Int.self, forKey: .currentReserveStamina)) ?? 0
        self.isReserveStaminaFull = (try? container.decode(Bool.self, forKey: .isReserveStaminaFull)) ?? false
    }

    enum CodingKeys: String, CodingKey {
        case maxStamina = "max_stamina"
        case currentStamina = "current_stamina"
        case staminaRecoverTime = "stamina_recover_time"
        case isReserveStaminaFull = "is_reserve_stamina_full"
        case currentReserveStamina = "current_reserve_stamina"
    }
}

// MARK: ReferencingBenchmarkTime

extension StaminaInfo4HSR: ReferencingBenchmarkTime {}
