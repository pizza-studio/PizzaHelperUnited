// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension Pizza.SupportedGame {
    public init?(dailyNoteResult: Result<any DailyNoteProtocol, any Error>) {
        switch dailyNoteResult {
        case let .success(data): self = data.game
        case .failure: return nil
        }
    }
}
