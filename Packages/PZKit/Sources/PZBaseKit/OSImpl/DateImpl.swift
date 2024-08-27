// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

//  时间工具

import Foundation

extension Date {
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
}

public func secondsToHoursMinutes(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        let cn = "unit.daysOf:%lld"
        return String(
            format: NSLocalizedString(cn, comment: "day"),
            seconds / (3600 * 24)
        )
    }
    let cn = "unit.HHMM:%lldHH%lldMM"
    return String(
        format: NSLocalizedString(cn, comment: "day"),
        seconds / 3600,
        (seconds % 3600) / 60
    )
}

public func secondsToHrOrDay(_ seconds: Int) -> String {
    if seconds / 3600 > 24 {
        return "unit.daysOf:\(seconds / (3600 * 24))"
    } else if seconds / 3600 > 0 {
        return "unit.hrs:\(seconds / 3600)"
    } else {
        return "unit.mins:\((seconds % 3600) / 60)"
    }
}

extension Date {
    public func adding(seconds: Int) -> Date {
        Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

public func relativeTimePointFromNow(second: Int) -> String {
    let dateFormatter = DateFormatter.Gregorian()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    dateFormatter.locale = Locale(identifier: Locale.current.identifier)

    let date = Calendar.current.date(
        byAdding: .second,
        value: second,
        to: Date()
    )!

    return dateFormatter.string(from: date)
}

// 计算日期相差天数
extension Date {
    public static func - (
        recent: Date,
        previous: Date
    )
        -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents(
            [.day],
            from: previous,
            to: recent
        ).day
        let month = Calendar.current.dateComponents(
            [.month],
            from: previous,
            to: recent
        ).month
        let hour = Calendar.current.dateComponents(
            [.hour],
            from: previous,
            to: recent
        ).hour
        let minute = Calendar.current.dateComponents(
            [.minute],
            from: previous,
            to: recent
        ).minute
        let second = Calendar.current.dateComponents(
            [.second],
            from: previous,
            to: recent
        ).second

        return (
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}

extension DateFormatter {
    public static func Gregorian() -> DateFormatter {
        let result = DateFormatter()
        result.locale = .init(identifier: "en_US_POSIX")
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
