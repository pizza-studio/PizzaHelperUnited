// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.APILang

extension HoYo {
    /// 米哈游 API 所用的语言标识。
    public enum APILang: String, CaseIterable, Sendable, Identifiable {
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
        case langCHS = "zh-cn"
        case langCHT = "zh-tw"

        // MARK: Public

        public static let cjkLanguages: [Self] = [.langCHS, .langCHT, .langJP, .langKR]

        public static let allCasesSorted: [Self] = {
            var result: [Self] = [.current] + cjkLanguages
            let prioritizesCJK = cjkLanguages.contains(.current)
            let index4NonCJK: [Self].Index = prioritizesCJK ? result.endIndex : 1
            result.insert(contentsOf: allCases, at: index4NonCJK)
            return result.reduce(into: [Self]()) { if !$0.contains($1) { $0.append($1) } }
        }()

        public static var current: Self {
            Locale.hoyoAPILanguage
        }

        public var id: String { rawValue }

        public func sanitized(by game: Pizza.SupportedGame) -> Self {
            guard game != .genshinImpact, [.langIT, .langTR].contains(self) else { return self }
            return .langEN
        }
    }
}

extension HoYo.APILang {
    public var localizedKey: String {
        "hoyo.lang.\(String(describing: self).replacingOccurrences(of: "lang", with: "").lowercased())"
    }

    public var localized: String {
        NSLocalizedString("\(localizedKey)", tableName: "HoYoLangNames", bundle: .currentSPM, comment: "")
    }
}

extension HoYo.APILang {
    public init?(langTag: String) {
        let langTag = langTag.lowercased()
        switch langTag.prefix(3) {
        case "chs":
            self = .langCHS
            return
        case "cht":
            self = .langCHT
            return
        default: break
        }
        switch langTag.prefix(2) {
        case "ja", "jp": self = .langJP
        case "ko", "kr": self = .langKR
        case "es": self = .langES
        case "th": self = .langTH
        case "id": self = .langID
        case "pt": self = .langPT
        case "de": self = .langDE
        case "fr": self = .langFR
        case "ru": self = .langRU
        case "en": self = .langEN
        case "vi": self = .langVI
        case "zh":
            switch langTag.count {
            case 7...:
                let middleTag = langTag.map(\.description)[3 ... 6].joined()
                switch middleTag {
                case "hans": self = .langCHS
                case "hant": self = .langCHT
                default: self = .langCHS
                }
            case 0 ... 6:
                let trailingTag = langTag.map(\.description)[3 ... 4].joined()
                switch trailingTag {
                case "hk", "mo", "tw", "yue": self = .langCHT
                case "cn", "my", "sg": self = .langCHS
                default: self = .langCHS
                }
            default:
                self = .langCHS
            }
        default: return nil
        }
    }
}

// MARK: - HoYo.APILang + Codable

extension HoYo.APILang: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let languageCode = HoYo.APILang(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid HoYo.APILang raw value: \(rawValue)"
            )
        }
        self = languageCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Locale {
    /// Get the language code used for miHoYo API according to current UI language preference.
    public static var hoyoAPILanguage: HoYo.APILang {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.currentSPM.preferredLocalizations.first
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
