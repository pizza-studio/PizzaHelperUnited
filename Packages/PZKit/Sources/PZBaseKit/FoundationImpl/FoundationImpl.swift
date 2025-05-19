// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import CryptoKit
import Foundation

/// This combination has been used too frequent
public typealias AbleToCodeSendHash = Codable & Sendable & Hashable

// MARK: - UserDefaults + Sendable

extension UserDefaults: @unchecked @retroactive Sendable {}

// MARK: - Debug Intel Dumper for URLRequest.

extension URLRequest {
    public func printDebugIntelIfDebugMode() {
        #if DEBUG
        print("---------------------------------------------")
        print(debugDescription)
        if let headerEX = allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try! encoder.encode(headerEX), encoding: .utf8)!)
        }
        print("---------------------------------------------")
        #endif
    }
}

extension Alamofire.DataRequest {
    public func printDebugIntelIfDebugMode() {
        convertible.urlRequest?.printDebugIntelIfDebugMode()
    }
}

// MARK: - Ask Bundle to tell App Build Number.

extension Bundle {
    public static func getAppVersionAndBuild() throws -> (version: String, build: String) {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            throw NSError(
                domain: "AppInfoError",
                code: 213,
                userInfo: [NSLocalizedDescriptionKey: "Failed to get the app's Info.plist."]
            )
        }

        guard let version = infoDictionary["CFBundleShortVersionString"] as? String,
              let build = infoDictionary["CFBundleVersion"] as? String else {
            throw NSError(
                domain: "AppInfoError",
                code: 233,
                userInfo: [NSLocalizedDescriptionKey: "Version or build number is missing."]
            )
        }

        return (version, build)
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
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

extension String.LocalizationValue {
    public var i18nBaseKit: String {
        String(localized: self, bundle: .module)
    }
}

extension String {
    /// - returns: the String, as an MD5 hash.
    public var md5: String {
        Insecure.MD5.hash(data: Data(utf8)).map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    public var sha256: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

extension String {
    public func convertPercentedSelfToDouble() -> Double? {
        var allChars = map { $0 }
        var shouldDivideBy100 = false
        if allChars.last == "%" {
            allChars = allChars.dropLast()
            shouldDivideBy100 = true
        }
        guard let numberResult = Double(String(allChars)) else { return nil }
        return shouldDivideBy100 ? (numberResult / 100) : numberResult
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

// MARK: - UUID Impl.

extension UUID {
    /// Converts an MD5 hash string into a UUID.
    /// - Parameter md5: A 32-character hexadecimal MD5 hash string.
    /// - Throws: An error if the MD5 string is invalid.
    /// - Returns: A UUID generated from the MD5 hash.
    public static func fromMD5(_ md5: String) throws -> UUID {
        // Ensure the MD5 string is valid (32 characters, hexadecimal)
        guard md5.count == 32, md5.range(of: "^[a-fA-F0-9]{32}$", options: .regularExpression) != nil else {
            throw NSError(domain: "InvalidMD5", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid MD5 string."])
        }

        // Convert the MD5 string into raw bytes
        var bytes = [UInt8]()
        var index = md5.startIndex
        for _ in 0 ..< 16 {
            let nextIndex = md5.index(index, offsetBy: 2)
            if let byte = UInt8(md5[index ..< nextIndex], radix: 16) {
                bytes.append(byte)
            }
            index = nextIndex
        }

        // Convert the raw bytes into a UUID
        let uuid = UUID(uuid: (
            bytes[0],
            bytes[1],
            bytes[2],
            bytes[3],
            bytes[4],
            bytes[5],
            bytes[6],
            bytes[7],
            bytes[8],
            bytes[9],
            bytes[10],
            bytes[11],
            bytes[12],
            bytes[13],
            bytes[14],
            bytes[15]
        ))
        return uuid
    }
}

// MARK: - Collection Extensions.

extension Collection {
    public func chunked(into size: Int) -> [[Self.Element]] where Self.Index == Int {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }

    public func indicesMeeting(condition: (Element) throws -> Bool) rethrows -> [Index]? {
        let indices = try indices.filter { try condition(self[$0]) }
        return indices.isEmpty ? nil : indices
    }
}

// MARK: - Bool Constructor with Equality checks.

extension Bool {
    public init<T: Comparable>(equalCheck lhs: T?, against rhs: T?) {
        guard let lhs, let rhs else { self = false; return }
        self = lhs == rhs
    }
}

extension Calendar {
    public static let gregorian = Calendar(identifier: .gregorian)
}

// MARK: - Date Implementations

extension Date {
    public enum RelationIdentifier {
        case today
        case tomorrow
        case other

        // MARK: Public

        public static func getRelationIdentifier(
            of date: Date,
            from benchmarkDate: Date = Date()
        )
            -> Self {
            let dayDiffer = Calendar.gregorian.component(.day, from: date) - Calendar
                .current.component(.day, from: benchmarkDate)
            switch dayDiffer {
            case 0: return .today
            case 1: return .tomorrow
            default: return .other
            }
        }
    }

    public func getRelativeDateString(benchmarkDate: Date = Date()) -> String {
        let relationIdentifier: RelationIdentifier = .getRelationIdentifier(of: self)
        let formatter = DateFormatter.GregorianPOSIX()
        var component = Locale.Components(locale: Locale.current)
        component.hourCycle = .zeroToTwentyThree
        formatter.locale = Locale(components: component)
        formatter.dateFormat = "H:mm"
        let datePrefix: String
        switch relationIdentifier {
        case .today:
            datePrefix = "date.relative.today"
            return datePrefix.i18nBaseKit + formatter.string(from: self)
        case .tomorrow:
            datePrefix = "date.relative.tomorrow"
            return datePrefix.i18nBaseKit + formatter.string(from: self)
        case .other:
            formatter.dateFormat = "E H:mm"
            return formatter.string(from: self)
        }
    }

    public var coolingDownTimeRemaining: TimeInterval {
        timeIntervalSinceReferenceDate - Date.now.timeIntervalSinceReferenceDate
    }

    public static func specify(day: Int, month: Int, year: Int) -> Date? {
        let month = max(1, min(12, month))
        let year = max(1965, min(9999, year))
        var day = max(1, min(31, day))
        var comps = DateComponents()
        comps.setValue(day, for: .day)
        comps.setValue(month, for: .month)
        comps.setValue(year, for: .year)
        let gregorian = Calendar(identifier: .gregorian)
        var date = gregorian.date(from: comps)
        while date == nil, day > 28 {
            day -= 1
            comps.setValue(day, for: .day)
            date = gregorian.date(from: comps)
        }
        return date
    }

    public func adding(seconds: Int) -> Date {
        Calendar.gregorian.date(byAdding: .second, value: seconds, to: self)!
    }

    public static func secondsToHoursMinutes(_ seconds: Int) -> String {
        if seconds / 3600 > 24 {
            return String(
                format: "unit.daysOf:%lld".i18nBaseKit,
                seconds / (3600 * 24)
            )
        }
        return String(
            format: "unit.HHMM:%lldHH%lldMM".i18nBaseKit,
            seconds / 3600,
            (seconds % 3600) / 60
        )
    }

    public static func secondsToHrOrDay(_ seconds: Int) -> String {
        if seconds / 3600 > 24 {
            "unit.daysOf:\(seconds / (3600 * 24))"
        } else if seconds / 3600 > 0 {
            "unit.hrs:\(seconds / 3600)"
        } else {
            "unit.mins:\((seconds % 3600) / 60)"
        }
    }

    public static func relativeTimePointFromNow(second: Int) -> String {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)

        let date = Calendar.gregorian.date(
            byAdding: .second,
            value: second,
            to: Date()
        )!

        return dateFormatter.string(from: date)
    }

    public struct IntervalDate: AbleToCodeSendHash {
        public let month: Int?
        public let day: Int?
        public let hour: Int?
        public let minute: Int?
        public let second: Int?
    }

    // 计算日期相差天数
    public static func - (
        recent: Date,
        previous: Date
    )
        -> IntervalDate {
        let day = Calendar.gregorian.dateComponents(
            [.day],
            from: previous,
            to: recent
        ).day
        let month = Calendar.gregorian.dateComponents(
            [.month],
            from: previous,
            to: recent
        ).month
        let hour = Calendar.gregorian.dateComponents(
            [.hour],
            from: previous,
            to: recent
        ).hour
        let minute = Calendar.gregorian.dateComponents(
            [.minute],
            from: previous,
            to: recent
        ).minute
        let second = Calendar.gregorian.dateComponents(
            [.second],
            from: previous,
            to: recent
        ).second

        return IntervalDate(
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}

extension DateFormatter {
    public static func GregorianPOSIX() -> DateFormatter {
        let result = DateFormatter()
        result.locale = .init(identifier: "en_US_POSIX")
        return result
    }

    public static func CurrentLocale() -> DateFormatter {
        let result = DateFormatter()
        result.locale = .init(identifier: Locale.current.identifier)
        return result
    }
}

extension TimeInterval {
    public static func sinceNow(to date: Date) -> Self {
        date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
    }

    public static func toNow(from date: Date) -> Self {
        Date().timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
    }

    public init(from dateA: Date, to dateB: Date) {
        self = dateB.timeIntervalSinceReferenceDate - dateA.timeIntervalSinceReferenceDate
    }
}

// MARK: - Data Implementation

extension Data {
    public func parseAs<T: Decodable>(
        _ type: T.Type, config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T {
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: self)
    }
}

extension Data? {
    public func parseAs<T: Decodable>(
        _ type: T.Type, config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T? {
        guard let this = self else { return nil }
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: this)
    }

    public func assertedParseAs<T: Decodable>(
        _ type: T.Type,
        config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T {
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: self ?? .init([]))
    }
}
