// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

public enum GachaItemRankType: Int {
    case three = 3
    case four = 4
    case five = 5

    // MARK: Lifecycle

    public init?(rawValueStr: String) {
        guard let intRawValue = Int(rawValueStr) else { return nil }
        switch intRawValue {
        case 3: self = .three
        case 4: self = .four
        case 5: self = .five
        default: return nil
        }
    }
}
