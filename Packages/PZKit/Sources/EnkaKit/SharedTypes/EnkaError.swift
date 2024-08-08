// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

extension Enka {
    public enum EKError: Error, LocalizedError {
        case langTableMatchFailure
        case queryTooFrequent(dateWhenRefreshable: Date)

        // MARK: Public

        public var description: String {
            switch self {
            case .langTableMatchFailure: return "rawValue"
            case let .queryTooFrequent(dateWhenRefreshable):
                let cd = dateWhenRefreshable.coolingDownTimeRemaining
                return "Query too frequent. Remaining cooling down time: \(cd) seconds."
            }
        }

        public var errorDescription: String? {
            description
        }
    }
}
