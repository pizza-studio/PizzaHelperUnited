// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - StaminaInfo4HSR

public struct StaminaInfo4HSR: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maxStamina = try container.decode(Int.self, forKey: .maxStamina)
        self._currentStamina = try container.decode(Int.self, forKey: .currentStamina)
        self._staminaRecoverTime = try TimeInterval(container.decode(Int.self, forKey: .staminaRecoverTime))
        self.currentReserveStamina = try container.decode(Int.self, forKey: .currentReserveStamina)
        self.isReserveStaminaFull = (try? container.decode(Bool.self, forKey: .isReserveStaminaFull)) ?? false
        self.staminaFullTimestamp = try container.decodeIfPresent(Double.self, forKey: .staminaFullTimestamp)
    }

    // MARK: Public

    /// Each primary stamina needs 6 minutes to recover
    public static let eachStaminaRecoveryTime: TimeInterval = 60 * 6

    /// Each backup stamina needs 6 minutes to recover
    public static let eachBackupStaminaRecoveryTime: TimeInterval = 60 * 18

    /// Max stamina (Primary).
    public let maxStamina: Int

    public let isReserveStaminaFull: Bool

    // Unix Timestamp.
    public let staminaFullTimestamp: Double?

    /// Reserved Stamina when data is fetched.
    public let currentReserveStamina: Int

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
        let restOfTime = _staminaRecoverTime - Date().timeIntervalSince(fetchTime)
        if restOfTime > 0 {
            return restOfTime
        } else {
            return 0
        }
    }

    /// The time when stamina is full
    public var fullTime: Date {
        if let staminaFullTimestamp {
            return .init(timeIntervalSince1970: staminaFullTimestamp)
        }
        return Date(timeInterval: _staminaRecoverTime, since: fetchTime)
    }

    /// The time when next stamina recover. If the stamina is full, return `nil`
    public var nextStaminaTime: Date? {
        let nextRecoverTimeInterval = remainingTime.truncatingRemainder(dividingBy: Self.eachStaminaRecoveryTime)
        if nextRecoverTimeInterval != 0 {
            return Date(timeInterval: nextRecoverTimeInterval + 1, since: .init())
        } else {
            return nil
        }
    }

    public var maxReserveStamina: Int { 2400 }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxStamina, forKey: .maxStamina)
        try container.encode(_currentStamina, forKey: .currentStamina)
        let recoverInterval = _staminaRecoverTime.asIntIfFinite() ?? 0
        try container.encode(recoverInterval, forKey: .staminaRecoverTime)
        try container.encode(currentReserveStamina, forKey: .currentReserveStamina)
        try container.encode(isReserveStaminaFull, forKey: .isReserveStaminaFull)
        try container.encodeIfPresent(staminaFullTimestamp, forKey: .staminaFullTimestamp)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case maxStamina = "max_stamina"
        case currentStamina = "current_stamina"
        case staminaRecoverTime = "stamina_recover_time"
        case isReserveStaminaFull = "is_reserve_stamina_full"
        case currentReserveStamina = "current_reserve_stamina"
        case staminaFullTimestamp = "stamina_full_ts"
    }

    // MARK: Private

    /// Stamina when data is fetched.
    private let _currentStamina: Int
    /// Recovery time interval when data is fetched.
    private let _staminaRecoverTime: TimeInterval

    /// The time this struct generated
    private let fetchTime: Date = .init()

    private var restOfStamina: Int {
        let amount = ceil(remainingTime / Self.eachStaminaRecoveryTime)
        return amount.asIntIfFinite() ?? 0
    }
}
