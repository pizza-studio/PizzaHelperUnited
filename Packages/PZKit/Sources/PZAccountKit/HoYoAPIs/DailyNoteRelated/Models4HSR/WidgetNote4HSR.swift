// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - WidgetNote4HSR

/// Daily note data from widget api. Contain more data than the `GeneralNote4HSR`
public struct WidgetNote4HSR: DecodableFromMiHoYoAPIJSONResult, Note4HSR {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInfo = try decoder.decode(StaminaInfo4HSR.self)
        self.assignmentInfo = try decoder.decode(AssignmentInfo4HSR.self)
        self.simulatedUniverseInfo = try decoder.decode(SimuUnivInfo4HSR.self)
        self.dailyTrainingInfo = try decoder.decode(DailyTrainingInfo4HSR.self)
    }

    // MARK: Public

    /// Stamina info
    public var staminaInfo: StaminaInfo4HSR
    /// Assignment info
    public var assignmentInfo: AssignmentInfo4HSR
    /// The time when this struct is generated
    public let fetchTime: Date = .init()

    public let simulatedUniverseInfo: SimuUnivInfo4HSR

    public let dailyTrainingInfo: DailyTrainingInfo4HSR
}

// MARK: BenchmarkTimeEditable

extension WidgetNote4HSR: BenchmarkTimeEditable {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> WidgetNote4HSR {
        var newNote4HSR = self
        newNote4HSR.staminaInfo = staminaInfo.replacingBenchmarkTime(newBenchmarkTime)
        newNote4HSR.assignmentInfo = assignmentInfo.replacingBenchmarkTime(newBenchmarkTime)
        return newNote4HSR
    }
}
