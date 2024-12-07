// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - RealtimeNote4HSR

/// Daily note data from widget api.
public struct RealtimeNote4HSR: DecodableFromMiHoYoAPIJSONResult, Note4HSR {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInfo = try decoder.decode(StaminaInfo4HSR.self)
        self.assignmentInfo = try decoder.decode(AssignmentInfo4HSR.self)
        self.simulatedUniverseInfo = try decoder.decode(SimuUnivInfo4HSR.self)
        self.dailyTrainingInfo = try decoder.decode(DailyTrainingInfo4HSR.self)
        self.optionalMetaData = try? decoder.decode(NoteMetaData4HSR.self)
        self.echoOfWarCostStatus = try? decoder.decode(EchoOfWarInfo4HSR.self)
    }

    // MARK: Public

    /// Stamina info
    public var staminaInfo: StaminaInfo4HSR
    /// Assignment info
    public var assignmentInfo: AssignmentInfo4HSR
    /// The time when this struct is generated
    public let fetchTime: Date = .init()
    /// Simulated Universe score completion status (weekly)
    public let simulatedUniverseInfo: SimuUnivInfo4HSR
    /// Daily Training Info
    public let dailyTrainingInfo: DailyTrainingInfo4HSR
    /// Echo of War (unable from Widget APIs)
    public let echoOfWarCostStatus: EchoOfWarInfo4HSR?
    /// Optional Metadata (unable from Widget APIs)
    public let optionalMetaData: NoteMetaData4HSR?
}

// MARK: BenchmarkTimeEditable

extension RealtimeNote4HSR: BenchmarkTimeEditable {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> RealtimeNote4HSR {
        var newNote4HSR = self
        newNote4HSR.staminaInfo = staminaInfo.replacingBenchmarkTime(newBenchmarkTime)
        newNote4HSR.assignmentInfo = assignmentInfo.replacingBenchmarkTime(newBenchmarkTime)
        return newNote4HSR
    }
}

// MARK: - Example

extension RealtimeNote4HSR {
    public static func exampleData() -> RealtimeNote4HSR {
        let exampleURL = Bundle.module.url(
            forResource: "hsr_realtime_note_example_miyoushe", withExtension: "json"
        )!
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! RealtimeNote4HSR.decodeFromMiHoYoAPIJSONResult(
            data: exampleData, debugTag: "GeneralNote4HSR.exampleData()"
        )
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }
}
