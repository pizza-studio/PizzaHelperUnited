// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4HSR

/// Daily note protocol. The result from 2 kind of note api use this protocol.
public protocol Note4HSR: BenchmarkTimeEditable, DailyNoteProtocol {
    /// Stamina info
    var staminaInfo: StaminaInfo4HSR { get }
    /// Assignment info
    var assignmentInfo: AssignmentInfo4HSR { get }
    /// The time when this struct is generated
    var fetchTime: Date { get }
}

extension Note4HSR {
    public static var game: Pizza.SupportedGame { .starRail }
}
