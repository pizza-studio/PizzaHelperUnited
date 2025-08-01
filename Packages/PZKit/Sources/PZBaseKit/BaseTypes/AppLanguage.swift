// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Defaults
import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ja // Japanese
    case ko // Korean
    case de // Deutsch
    case fr // French
    case es // Spanish
    case it // Italian
    case ru // Russian
    case vi // Vietnamese
    case fil // Filipino

    // MARK: Public

    public static let defaultsKeyName = "AppleLanguages"

    public static var current: Locale {
        let loaded = UserDefaults.standard.array(forKey: defaultsKeyName) as? [String]
        guard let firstValidValueRaw = loaded?.first else { return .autoupdatingCurrent }
        return .init(identifier: firstValidValueRaw)
    }

    public var id: String { rawValue }

    @available(iOS 15.0, macCatalyst 15.0, *) public var localizedDescription: String {
        "app.language.\(rawValue)".i18nBaseKit
    }

    public var savedValue: [String] {
        [rawValue]
    }
}
