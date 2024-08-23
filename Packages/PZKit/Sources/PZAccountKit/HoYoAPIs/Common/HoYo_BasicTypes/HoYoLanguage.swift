// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - HoYo.APILang

extension HoYo {
    /// 米哈游 API 所用的语言标识。
    public enum APILang: String, CaseIterable, Sendable, Identifiable {
        case langCHS = "zh-cn"
        case langCHT = "zh-tw"
        case langDE = "de-de"
        case langEN = "en-us"
        case langES = "es-es"
        case langFR = "fr-fr"
        case langID = "id-id"
        case langIT = "it-it" // 原神专用
        case langJP = "ja-jp"
        case langKR = "ko-kr"
        case langPT = "pt-pt"
        case langRU = "ru-ru"
        case langTH = "th-th"
        case langTR = "tr-tr" // 原神专用
        case langVI = "vi-vn"

        // MARK: Public

        public static var current: Self {
            Locale.hoyoAPILanguage
        }

        public var id: String { rawValue }
    }
}

extension Locale {
    /// Get the language code used for miHoYo API according to current UI language preference.
    public static var hoyoAPILanguage: HoYo.APILang {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.module.preferredLocalizations.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return .langCHS
        case "zh-hant": return .langCHT
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return .langCHS
        case "zh-tw": return .langCHT
        default: break
        }
        switch languageCode.prefix(2).lowercased() {
        case "ja", "jp": return .langJP
        case "ko", "kr": return .langKR
        default: break
        }
        return .init(rawValue: languageCode.prefix(2).description) ?? .langEN
    }
}
