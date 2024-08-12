// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

extension Pizza {
    public enum SupportedGame: String, Sendable, Identifiable, Hashable, Codable {
        case genshinImpact = "GI"
        case starRail = "HSR"

        // MARK: Public

        public var id: String { rawValue }

        public var uidPrefix: String {
            switch self {
            case .genshinImpact: "GI"
            case .starRail: "SR"
            }
        }
    }
}
