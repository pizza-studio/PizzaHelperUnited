// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CryptoKit
import Foundation

extension Date {
    public var coolingDownTimeRemaining: TimeInterval {
        timeIntervalSinceReferenceDate - Date.now.timeIntervalSinceReferenceDate
    }
}

// MARK: - Swift Extension to round doubles.

extension Double {
    /// Rounds the double to decimal places value
    public func roundToPlaces(places: Int = 1, round: FloatingPointRoundingRule? = nil) -> Double {
        guard places > 0 else { return self }
        var precision = 1.0
        for _ in 0 ..< places {
            precision *= 10
        }
        var amped = precision * self
        if let round {
            amped.round(round)
        } else {
            amped = amped.rounded()
        }

        return Double(amped / precision)
    }
}

// MARK: - Decoding Strategy for Decoding UpperCamelCases

extension JSONDecoder.KeyDecodingStrategy {
    public static var convertFromPascalCase: Self {
        .custom { keys in
            PascalCaseKey(stringValue: keys.last!.stringValue)
        }
    }
}

// MARK: - PascalCaseKey

private struct PascalCaseKey: CodingKey {
    // MARK: Lifecycle

    init(stringValue str: String) {
        let allCapicalized = str.filter(\.isLowercase).isEmpty
        guard !allCapicalized else {
            self.stringValue = str.lowercased()
            self.intValue = nil
            return
        }
        var count = 0
        perCharCheck: for char in str {
            if char.isUppercase {
                count += 1
            } else {
                break perCharCheck
            }
        }
        if count > 1 {
            count -= 1
        }
        self.stringValue = str.prefix(count).lowercased() + str.dropFirst(count)
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    // MARK: Internal

    let stringValue: String
    let intValue: Int?
}

// MARK: - String Implementations.

extension String {
    public var asURL: URL {
        // swiftlint:disable force_unwrapping
        URL(string: self)!
        // swiftlint:enable force_unwrapping
    }
}

extension String {
    public var i18nBaseKit: String {
        NSLocalizedString(self, bundle: Bundle.module, comment: "")
    }
}

extension String {
    /// - returns: the String, as an MD5 hash.
    public var md5: String {
        Insecure.MD5.hash(data: Data(utf8)).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

// MARK: - Locale Implementations.

extension Locale {
    public static var isUILanguagePanChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(3).description == "zh-"
    }

    public static var isUILanguageJapanese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.prefix(2).description == "ja"
    }

    public static var isUILanguageSimplifiedChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hans") || firstLocale.contains("zh-CN")
    }

    public static var isUILanguageTraditionalChinese: Bool {
        guard let firstLocale = Bundle.main.preferredLocalizations.first
        else { return false }
        return firstLocale.contains("zh-Hant") || firstLocale
            .contains("zh-TW") || firstLocale.contains("zh-HK")
    }
}

// MARK: - AnyLocalizedError

public enum AnyLocalizedError: LocalizedError {
    case localizedError(LocalizedError)
    case otherError(Error)

    // MARK: Lifecycle

    public init(_ error: Error) {
        if let error = error as? LocalizedError {
            self = .localizedError(error)
        } else {
            self = .otherError(error)
        }
    }

    // MARK: Public

    public var errorDescription: String? {
        switch self {
        case let .localizedError(localizedError):
            localizedError.errorDescription
        case let .otherError(error):
            error.localizedDescription
        }
    }
}
