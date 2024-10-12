// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - DailyNoteProtocol

public protocol DailyNoteProtocol: Sendable {
    static var game: Pizza.SupportedGame { get }
}

extension DailyNoteProtocol {
    public var game: Pizza.SupportedGame { Self.game }
}

extension PZProfileSendable {
    public func getDailyNote() async throws -> DailyNoteProtocol {
        await HoYo.waitFor450ms()
        return switch game {
        case .genshinImpact: try await HoYo.note4GI(profile: self)
        case .starRail: try await HoYo.note4HSR(profile: self)
        case .zenlessZone: try await HoYo.note4ZZZ(profile: self)
        }
    }
}

extension PZProfileMO {
    public func getDailyNote() async throws -> DailyNoteProtocol {
        try await asSendable.getDailyNote()
    }
}
