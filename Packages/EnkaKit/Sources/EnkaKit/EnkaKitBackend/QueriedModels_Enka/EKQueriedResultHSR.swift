// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - Enka.QueriedResultHSR

extension Enka {
    public struct QueriedResultHSR: Codable, Hashable, Sendable, EKQueryResultProtocol {
        public typealias QueriedProfileType = Enka.QueriedProfileHSR
        public typealias DBType = Enka.EnkaDB4HSR

        public static var game: Enka.GameType { .starRail }

        public var detailInfo: QueriedProfileHSR?
        public var uid: String?
        public let message: String?
    }
}
