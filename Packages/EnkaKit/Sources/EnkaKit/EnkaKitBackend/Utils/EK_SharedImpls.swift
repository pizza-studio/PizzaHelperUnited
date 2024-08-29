// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Enka.GameType

extension Enka {
    public typealias GameType = Pizza.SupportedGame
}

extension Pizza.SupportedGame {
    public var debugTag: String {
        switch self {
        case .genshinImpact: "GI"
        case .starRail: "SR"
        case .zenlessZone: "ZZ"
        }
    }

    public var localAssetNamePrefix: String {
        switch self {
        case .genshinImpact: "gi_"
        case .starRail: "hsr_"
        case .zenlessZone: "zzz_" // 临时设定。
        }
    }
}

extension Enka {
    public typealias RawLocTables = [String: LocTable]
    public typealias LocTable = [String: String]

    /// 星穹铁道所支持的语言数量比原神略少，所以取两者之交集。
    public static let allowedLangTags: [String] = [
        "en", "ru", "vi", "th", "pt", "ko",
        "ja", "id", "fr", "es", "de", "zh-tw", "zh-cn",
    ]

    public static var currentLangTag: String { Locale.langCodeForEnkaAPI }

    /// 不用于 EnkaDB 自身的辞典检索。
    public static var currentWebAPILangTag: String {
        switch currentLangTag {
        case "de": "de-de"
        case "en": "en-us"
        case "es": "es-es"
        case "fr": "fr-fr"
        case "id": "id-id"
        case "ja": "ja-jp"
        case "ko": "ko-kr"
        case "pt": "pt-pt"
        case "ru": "ru-ru"
        case "th": "th-th"
        case "vi": "vi-vn"
        case "zh-cn": "zh-cn"
        case "zh-tw": "zh-tw"
        default: "en-us"
        }
    }

    public static func convertLangTagToWebAPILangTag(oldTag: String) -> String {
        switch oldTag {
        case "de": "de-de"
        case "en": "en-us"
        case "es": "es-es"
        case "fr": "fr-fr"
        case "id": "id-id"
        case "ja": "ja-jp"
        case "ko": "ko-kr"
        case "pt": "pt-pt"
        case "ru": "ru-ru"
        case "th": "th-th"
        case "vi": "vi-vn"
        case "zh-cn": "zh-cn"
        case "zh-tw": "zh-tw"
        default: "en-us"
        }
    }

    public static func sanitizeLangTag(_ target: some StringProtocol) -> String {
        var target = target.lowercased()
        if target.prefix(2) == "zh" {
            if target.contains("cht") || target.contains("hant") {
                target = "zh-tw"
            } else if target.contains("chs") || target.contains("hans") {
                target = "zh-cn"
            }
        }
        if !Self.allowedLangTags.contains(target) {
            target = "en"
        }
        return target
    }
}

// MARK: - EnkaAPI LangCode

extension Locale {
    public static var langCodeForEnkaAPI: String {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.module.preferredLocalizations.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return "zh-cn"
        case "zh-hant": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return "zh-cn"
        case "zh-tw": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(2).lowercased() {
        case "ja", "jp": return "ja"
        case "ko", "kr": return "ko"
        default: break
        }
        let valid = Enka.allowedLangTags.contains(languageCode)
        return valid ? languageCode.prefix(2).description : "en"
    }
}

// MARK: - Data Implementation

extension Data {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

extension Data? {
    public func parseAs<T: Decodable>(_ type: T.Type) throws -> T? {
        guard let this = self else { return nil }
        return try JSONDecoder().decode(T.self, from: this)
    }

    public func assertedParseAs<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self ?? .init([]))
    }
}

extension Bundle {
    public static let enka = Bundle.module
}

extension String {
    public var i18nEnka: String {
        NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
}
