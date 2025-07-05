// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension Enka {
    public enum EKError: Error, LocalizedError {
        case langTableMatchingFailure
        case queryTooFrequent(dateWhenRefreshable: Date)
        case queryFailure(uid: String, game: Enka.GameType, message: String)

        // MARK: Public

        public var description: String {
            switch self {
            case .langTableMatchingFailure: return "rawValue"
            case let .queryTooFrequent(dateWhenRefreshable):
                let cd = dateWhenRefreshable.coolingDownTimeRemaining
                return "Query too frequent. Remaining cooling down time: \(cd) seconds."
            case let .queryFailure(uid: uid, game: game, message: message):
                return "Enka Query Failure. UID(\(game.debugTag)): \(uid), message: \(message)"
            }
        }

        public var localizedDescription: String {
            description
        }

        public var errorDescription: String? {
            description
        }
    }
}
