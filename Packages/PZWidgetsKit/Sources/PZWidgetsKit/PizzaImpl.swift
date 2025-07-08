// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    public init?(dailyNoteResult: Result<any DailyNoteProtocol, any Error>) {
        switch dailyNoteResult {
        case let .success(data): self = data.game
        case .failure: return nil
        }
    }
}
