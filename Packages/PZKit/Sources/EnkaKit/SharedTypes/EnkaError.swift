// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension Enka {
    public enum EKError: String, Error, LocalizedError {
        case langTableMatchFailure

        // MARK: Public

        public var description: String {
            rawValue
        }

        public var errorDescription: String? {
            description
        }
    }
}
