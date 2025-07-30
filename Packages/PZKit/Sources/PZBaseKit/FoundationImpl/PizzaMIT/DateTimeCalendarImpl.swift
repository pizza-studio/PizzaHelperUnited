// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation

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

    @available(iOS 16.0, macCatalyst 16.0, *)
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
        timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
    }

    public static func specify(day: Int, month: Int, year: Int, timeZone: TimeZone? = nil) -> Date? {
        let month = max(1, min(12, month))
        let year = max(1965, min(9999, year))
        var day = max(1, min(31, day))
        var comps = DateComponents()
        comps.setValue(day, for: .day)
        comps.setValue(month, for: .month)
        comps.setValue(year, for: .year)
        comps.timeZone = timeZone
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

    @available(iOS 15.0, macCatalyst 15.0, *)
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
