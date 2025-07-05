// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - GachaKit

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public enum GachaKit {}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaKit {
    public static func getServerTimeZoneDelta(uid: String, game: Pizza.SupportedGame) -> Int {
        HoYo.Server(uid: uid, game: game)?.timeZoneDelta ?? 8
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension DateFormatter {
    public static func forUIGFEntry(
        timeZoneDelta: Int
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDelta * 3600)
        return dateFormatter
    }

    public static var forUIGFFileName: DateFormatter {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter
    }

    public static func forUIGFEntry(
        timeZoneDeltaAsSeconds: Int
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDeltaAsSeconds)
        return dateFormatter
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension TimeZone {
    public init?(uid: String, game: Pizza.SupportedGame) {
        let server = HoYo.Server(uid: uid, game: game)
        guard let server else { return nil }
        let timeZone = TimeZone(secondsFromGMT: server.timeZoneDelta * 3600)
        guard let timeZone else { return nil }
        self = timeZone
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension Date {
    public func asUIGFDate(
        timeZoneDelta: Int
    )
        -> String {
        DateFormatter.forUIGFEntry(timeZoneDelta: timeZoneDelta).string(from: self)
    }

    public init?(_ hoyoExpression: String, tzDelta: Int) {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: tzDelta * 3600)
        guard let date = dateFormatter.date(from: hoyoExpression) else { return nil }
        self = date
    }

    public static func shiftUIGFTimeStampTimeZone(
        from oldTimeZoneDelta: Int,
        to newTimeZoneDelta: Int,
        against targetTimeStr: inout String
    ) throws {
        guard oldTimeZoneDelta != newTimeZoneDelta else { return }
        let formatterOld = DateFormatter.forUIGFEntry(timeZoneDelta: oldTimeZoneDelta)
        let formatterNew = DateFormatter.forUIGFEntry(timeZoneDelta: newTimeZoneDelta)
        let dateParsed = formatterOld.date(from: targetTimeStr)
        guard let dateParsed else {
            throw GachaKit.EntryException.timeRawValueNotParsable(rawString: targetTimeStr)
        }
        targetTimeStr = formatterNew.string(from: dateParsed)
    }

    public static func shiftUIGFTimeStampTimeZone(
        formatterOld: DateFormatter, formatterNew: DateFormatter,
        against targetTimeStr: inout String
    ) throws {
        guard formatterOld.timeZone != formatterNew.timeZone else { return }
        let dateParsed = formatterOld.date(from: targetTimeStr)
        guard let dateParsed else {
            throw GachaKit.EntryException.timeRawValueNotParsable(rawString: targetTimeStr)
        }
        targetTimeStr = formatterNew.string(from: dateParsed)
    }
}

// MARK: - GachaKit.EntryException

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaKit {
    public enum EntryException: Error, LocalizedError {
        case timeRawValueNotParsable(rawString: String)

        // MARK: Public

        public var errorDescription: String? { localizedDescription }

        public var description: String { localizedDescription }

        public var localizedDescription: String {
            switch self {
            case let .timeRawValueNotParsable(rawString):
                "gachaKit.EntryException.timeRawValueNotParsable".i18nGachaKit
                    + " // \(rawString)"
            }
        }
    }

    public enum FileExchangeException: Error, LocalizedError, CustomStringConvertible {
        case accessFailureComDlg32
        case fileNotExist
        case decodingError(Error)
        case uigfEntryInsertionError(Error)
        case otherError(Error)

        // MARK: Public

        public var description: String { localizedDescription }

        public var errorDescription: String? { localizedDescription }

        public var localizedDescription: String {
            switch self {
            case .accessFailureComDlg32:
                "gachaKit.FileExchangeException.accessFailureComDlg32".i18nGachaKit
            case .fileNotExist:
                "gachaKit.FileExchangeException.fileNotExist".i18nGachaKit
            case let .uigfEntryInsertionError(error):
                "gachaKit.FileExchangeException.uigfEntryInsertionError".i18nGachaKit
                    + " // \(error)"
            case let .decodingError(error):
                "gachaKit.FileExchangeException.fileParseFailure".i18nGachaKit
                    + " // \(error)"
            case let .otherError(error):
                "\(error)"
            }
        }
    }
}

// MARK: - UIGF Gacha Entry Date String Format Fixer APIs.

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension String {
    /// Corrects malformed date strings to "yyyy-MM-dd HH:mm:ss" format
    /// Handles cases where DateFormatter produces incorrect formats like:
    /// - "2020-04-04 3:03:03 PM"
    /// - "2020-04-04 下午3:03:03"
    public func correctedUIGFDateFormat() -> String {
        // First check if string already matches desired format
        let pattern = #"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$"#
        if range(of: pattern, options: .regularExpression) != nil {
            return self
        }
        // Set up formatter for output
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Setup input formatters
        let inputFormatters: [(DateFormatter, String)] = [
            // For "3:03:03 PM" style
            {
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: "en_US")
                fmt.dateFormat = "yyyy-MM-dd h:mm:ss a"
                return (fmt, "English 12-hour")
            }(),
            // For Chinese locale style
            {
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: "zh_CN")
                fmt.dateFormat = "yyyy-MM-dd ah:mm:ss"
                return (fmt, "Chinese 12-hour")
            }(),
        ]
        // Try each formatter
        for (formatter, _) in inputFormatters {
            if let date = formatter.date(from: self) {
                return outputFormatter.string(from: date)
            }
        }
        return self
    }

    /// A Boolean value indicating whether the string matches the "yyyy-MM-dd HH:mm:ss" format.
    public var isUIGFDateTimeFormat: Bool {
        // Check basic length
        guard count == 19 else { return false }

        // Check delimiters positions
        guard self[4] == "-",
              self[7] == "-",
              self[10] == " ",
              self[13] == ":",
              self[16] == ":" else {
            return false
        }

        // Extract components
        let year = Int(self[0 ... 3])
        let month = Int(self[5 ... 6])
        let day = Int(self[8 ... 9])
        let hour = Int(self[11 ... 12])
        let minute = Int(self[14 ... 15])
        let second = Int(self[17 ... 18])

        // Validate all components exist
        guard let year = year,
              let month = month,
              let day = day,
              let hour = hour,
              let minute = minute,
              let second = second else {
            return false
        }

        // Validate ranges
        guard (1 ... 12).contains(month),
              (1 ... 31).contains(day),
              (0 ... 23).contains(hour),
              (0 ... 59).contains(minute),
              (0 ... 59).contains(second) else {
            return false
        }

        // Validate days in month
        let daysInMonth = switch month {
        case 4, 6, 9, 11: 30
        case 2:
            isLeapYear(year) ? 29 : 28
        default: 31
        }

        return day <= daysInMonth
    }

    /// String subscript for getting character at index
    private subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }

    /// String subscript for getting substring in range
    private subscript(r: ClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[start ... end]
    }

    /// Check if a year is leap year
    private func isLeapYear(_ year: Int) -> Bool {
        year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
    }
}
