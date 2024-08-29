// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - DailyNoteProtocol

public protocol DailyNoteProtocol {
    static var game: Pizza.SupportedGame { get }
}

extension DailyNoteProtocol {
    public var game: Pizza.SupportedGame { Self.game }
}

extension PZProfileMO {
    public func getDailyNote() async throws -> DailyNoteProtocol? {
        switch game {
        case .genshinImpact: try await HoYo.note4GI(profile: self)
        case .starRail: try await HoYo.note4HSR(profile: self)
        case .zenlessZone: nil // TODO: 待 Lava 补充，回头实作完毕之后把这个函式的结果去掉 nullability。
        }
    }
}
