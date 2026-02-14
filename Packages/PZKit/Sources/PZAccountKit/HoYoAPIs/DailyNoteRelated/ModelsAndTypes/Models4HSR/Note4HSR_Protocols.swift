// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4HSR

/// Daily note protocol. The result from 2 kind of note api use this protocol.
public protocol Note4HSR: DailyNoteProtocol, AbleToCodeSendHash {
    /// Stamina info
    var staminaInfo: StaminaInfo4HSR { get }
    /// The time when this struct is generated
    var fetchTime: Date { get }
    /// Simulated Universe score completion status (weekly)
    var simulatedUniverseInfo: SimuUnivInfo4HSR { get }
    /// Currency Wars score completion status (weekly)
    var currencyWarsInfo: CurrencyWarsInfo4HSR? { get }
    /// Daily Training Info
    var dailyTrainingInfo: DailyTrainingInfo4HSR { get }
    /// Echo of War (unable from Widget APIs)
    var echoOfWarCostStatus: EchoOfWarInfo4HSR? { get }
    /// Optional Metadata (unable from Widget APIs)
    var optionalMetaData: NoteMetaData4HSR? { get }
}

extension Note4HSR {
    public static var game: Pizza.SupportedGame { .starRail }
}
