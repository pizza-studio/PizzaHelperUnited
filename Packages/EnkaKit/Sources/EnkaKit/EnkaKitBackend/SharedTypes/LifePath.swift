// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - Enka.LifePath

extension Enka {
    public enum LifePath: String, Codable, Hashable, Sendable, CaseIterable {
        case none = "None"
        case destruction = "Warrior"
        case hunt = "Rogue"
        case erudition = "Mage"
        case harmony = "Shaman"
        case nihility = "Warlock"
        case preservation = "Knight"
        case abundance = "Priest"
    }
}

extension Enka.LifePath {
    public var iconFileName: String {
        String(describing: self).capitalized
    }

    public var iconAssetName: String {
        "path_\(String(describing: self).capitalized)"
    }
}
