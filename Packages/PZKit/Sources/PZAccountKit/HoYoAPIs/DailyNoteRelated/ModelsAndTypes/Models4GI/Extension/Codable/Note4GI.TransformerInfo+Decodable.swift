// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - TransformerInfo4GI

// MARK: Decodable

extension FullNote4GI.TransformerInfo4GI {
    public init(from decoder: Decoder) throws {
        let basicContainer = try decoder.container(keyedBy: BasicCodingKeys.self)
        let container = try basicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .transformer)
        self.obtained = try container.decode(Bool.self, forKey: .obtained)

        let recoveryTimeContainer = try container.nestedContainer(
            keyedBy: RecoveryTimeCodingKeys.self,
            forKey: .recoveryTime
        )
        let reached = try recoveryTimeContainer.decode(Bool.self, forKey: .reached)
        if reached {
            self.recoveryTime = .init()
        } else {
            let day = try recoveryTimeContainer.decode(Int.self, forKey: .day)
            let minute = try recoveryTimeContainer.decode(Int.self, forKey: .minute)
            let hour = try recoveryTimeContainer.decode(Int.self, forKey: .hour)
            let second = try recoveryTimeContainer.decode(Int.self, forKey: .second)
            let timeInterval = TimeInterval() + Double(day * 24 * 60 * 60) + Double(minute * 60) +
                Double(hour * 60 * 60) + Double(second)
            self.recoveryTime = Date(timeIntervalSinceNow: timeInterval)
        }
    }

    private enum BasicCodingKeys: String, CodingKey {
        case transformer
    }

    private enum CodingKeys: String, CodingKey {
        case obtained
        case recoveryTime = "recovery_time"
    }

    private enum RecoveryTimeCodingKeys: String, CodingKey {
        case day = "Day"
        case minute = "Minute"
        case second = "Second"
        case hour = "Hour"
        case reached
    }
}

// MARK: Encodable

extension FullNote4GI.TransformerInfo4GI {
    public func encode(to encoder: Encoder) throws {
        var basicContainer = encoder.container(keyedBy: BasicCodingKeys.self)
        var container = basicContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .transformer)
        try container.encode(obtained, forKey: .obtained)

        var recoveryTimeContainer = container.nestedContainer(
            keyedBy: RecoveryTimeCodingKeys.self,
            forKey: .recoveryTime
        )
        let now = Date()
        let interval = recoveryTime.timeIntervalSince(now)
        if interval <= 0 {
            try recoveryTimeContainer.encode(true, forKey: .reached)
            try recoveryTimeContainer.encode(0, forKey: .day)
            try recoveryTimeContainer.encode(0, forKey: .hour)
            try recoveryTimeContainer.encode(0, forKey: .minute)
            try recoveryTimeContainer.encode(0, forKey: .second)
        } else {
            guard let totalSeconds = interval.asIntIfFinite() else {
                try recoveryTimeContainer.encode(true, forKey: .reached)
                try recoveryTimeContainer.encode(0, forKey: .day)
                try recoveryTimeContainer.encode(0, forKey: .hour)
                try recoveryTimeContainer.encode(0, forKey: .minute)
                try recoveryTimeContainer.encode(0, forKey: .second)
                return
            }
            try recoveryTimeContainer.encode(false, forKey: .reached)
            let day = totalSeconds / (24 * 3600)
            let hour = (totalSeconds % (24 * 3600)) / 3600
            let minute = (totalSeconds % 3600) / 60
            let second = totalSeconds % 60
            try recoveryTimeContainer.encode(day, forKey: .day)
            try recoveryTimeContainer.encode(hour, forKey: .hour)
            try recoveryTimeContainer.encode(minute, forKey: .minute)
            try recoveryTimeContainer.encode(second, forKey: .second)
        }
    }
}
