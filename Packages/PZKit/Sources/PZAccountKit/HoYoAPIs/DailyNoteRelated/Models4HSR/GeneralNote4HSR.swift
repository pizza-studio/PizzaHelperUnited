// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GeneralNote4HSR

/// A struct representing the result of note API
public struct GeneralNote4HSR: DecodableFromMiHoYoAPIJSONResult, Note4HSR {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.staminaInfo = try decoder.decode(StaminaInfo4HSR.self)
        self.assignmentInfo = try decoder.decode(AssignmentInfo4HSR.self)
    }

    // MARK: Public

    /// Stamina info
    public var staminaInfo: StaminaInfo4HSR
    /// Assignment info
    public var assignmentInfo: AssignmentInfo4HSR
    /// The time when this struct is generated
    public let fetchTime: Date = .init()
}

// MARK: BenchmarkTimeEditable

extension GeneralNote4HSR: BenchmarkTimeEditable {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> GeneralNote4HSR {
        var newNote4HSR = self
        newNote4HSR.staminaInfo = staminaInfo.replacingBenchmarkTime(newBenchmarkTime)
        newNote4HSR.assignmentInfo = assignmentInfo.replacingBenchmarkTime(newBenchmarkTime)
        return newNote4HSR
    }
}

// MARK: - Example

extension GeneralNote4HSR {
    public static func example() -> Note4HSR {
        let exampleURL = Bundle.module.url(forResource: "hsr_general_note_example", withExtension: "json")!
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        let exampleData = try! Data(contentsOf: exampleURL)
        return try! GeneralNote4HSR.decodeFromMiHoYoAPIJSONResult(
            data: exampleData
        ) as Note4HSR
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }
}
