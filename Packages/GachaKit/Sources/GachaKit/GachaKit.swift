// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - GachaKit

public enum GachaKit {}

extension GachaKit {
    public static func getServerTimeZoneDelta(uid: String, game: Pizza.SupportedGame) -> Int {
        HoYo.Server(uid: uid, game: game)?.timeZoneDelta ?? 8
    }
}

extension DateFormatter {
    public static func forUIGFEntry(
        timeZoneDelta: Int
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDelta * 3600)
        return dateFormatter
    }

    public static var forUIGFFileName: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
    }

    public static func forUIGFEntry(
        timeZoneDeltaAsSeconds: Int
    )
        -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = .init(secondsFromGMT: timeZoneDeltaAsSeconds)
        return dateFormatter
    }
}

extension TimeZone {
    public init?(uid: String, game: Pizza.SupportedGame) {
        let server = HoYo.Server(uid: uid, game: game)
        guard let server else { return nil }
        let timeZone = TimeZone(secondsFromGMT: server.timeZoneDelta * 3600)
        guard let timeZone else { return nil }
        self = timeZone
    }
}

extension Date {
    public func asUIGFDate(
        timeZoneDelta: Int
    )
        -> String {
        DateFormatter.forUIGFEntry(timeZoneDelta: timeZoneDelta).string(from: self)
    }

    public init?(_ hoyoExpression: String, tzDelta: Int) {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
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
