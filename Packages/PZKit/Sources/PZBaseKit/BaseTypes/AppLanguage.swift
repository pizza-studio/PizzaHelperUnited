// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

public enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ja

    // MARK: Public

    public static let defaultsKeyName = "AppleLanguages"

    public var id: String { rawValue }

    public var localizedDescription: String {
        "app.language.\(rawValue)".i18nBaseKit
    }

    public var savedValue: [String] {
        [rawValue]
    }
}
