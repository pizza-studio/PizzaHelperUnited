// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - TranslationResult

struct TranslationResult: Decodable {
    struct Translation: Decodable, Identifiable {
        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.nameTextMapHash = try container.decode(Int.self, forKey: .nameTextMapHash)
            self.target = try container.decode(String.self, forKey: .target)
            self.targetLanguage = try container.decode(DictionaryLanguage.self, forKey: .targetLanguage)
            let rawTransMap = try container.decode([String: String].self, forKey: .translationDictionary)
            var temp: [DictionaryLanguage: String] = .init()
            for (key, value) in rawTransMap {
                if let key = DictionaryLanguage(rawValue: key) {
                    temp[key] = value
                }
            }
            self.translationDictionary = temp
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case nameTextMapHash = "vocabulary_id"
            case target
            case targetLanguage = "target_lang"
            case translationDictionary = "lan_dict"
        }

        let nameTextMapHash: Int
        let target: String
        let targetLanguage: DictionaryLanguage
        let translationDictionary: [DictionaryLanguage: String]

        var id: Int { nameTextMapHash }
    }

    enum CodingKeys: String, CodingKey {
        case totalPage = "total_page"
        case translations = "results"
    }

    var totalPage: Int
    var translations: [Translation]
}

// MARK: - DictionaryLanguage

enum DictionaryLanguage: String, Decodable {
    case english = "en"
    case portuguese = "pt"
    case japanese = "jp"
    case indonesian = "id"
    case korean = "kr"
    case thai = "th"
    case french = "fr"
    case simplifiedChinese = "chs"
    case russian = "ru"
    case german = "de"
    case traditionalChinese = "cht"
    case spanish = "es"
    case vietnamese = "vi"
}

// MARK: CustomStringConvertible

extension DictionaryLanguage: CustomStringConvertible {
    var description: String {
        switch self {
        case .english:
            return "tool.dictionary.language.english".i18nDictKit
        case .portuguese:
            return "tool.dictionary.language.portuguese".i18nDictKit
        case .japanese:
            return "tool.dictionary.language.japanese".i18nDictKit
        case .indonesian:
            return "tool.dictionary.language.indonesian".i18nDictKit
        case .korean:
            return "tool.dictionary.language.korean".i18nDictKit
        case .thai:
            return "tool.dictionary.language.thai".i18nDictKit
        case .french:
            return "tool.dictionary.language.french".i18nDictKit
        case .simplifiedChinese:
            return "tool.dictionary.language.simplified_chinese".i18nDictKit
        case .russian:
            return "tool.dictionary.language.russian".i18nDictKit
        case .german:
            return "tool.dictionary.language.german".i18nDictKit
        case .traditionalChinese:
            return "tool.dictionary.language.traditional_chinese".i18nDictKit
        case .spanish:
            return "tool.dictionary.language.spanish".i18nDictKit
        case .vietnamese:
            return "tool.dictionary.language.vietnamese".i18nDictKit
        }
    }
}
