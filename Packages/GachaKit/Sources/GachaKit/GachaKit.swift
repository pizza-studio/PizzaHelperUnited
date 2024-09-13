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
}
