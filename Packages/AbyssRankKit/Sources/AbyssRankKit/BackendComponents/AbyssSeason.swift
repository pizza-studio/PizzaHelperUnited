// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

typealias AbyssSeason = Int

extension AbyssSeason {
    static func from(_ date: Date) -> Self {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyyMM"
        let yearMonth = Int(dateFormatter.string(from: date))! * 10
        if Calendar.gregorian.component(.day, from: date) > 15 {
            return yearMonth + 1
        } else {
            return yearMonth
        }
    }

    static func now() -> Self {
        from(Date())
    }

    var startDateOfSeason: Date {
        let seasonString = String(self)
        let formatter = DateFormatter.GregorianPOSIX()
        formatter.dateFormat = "yyyyMM"
        let yearMonth = formatter.date(from: String(seasonString.prefix(6)))!
        let year = Calendar.gregorian.component(.year, from: yearMonth)
        let month = Calendar.gregorian.component(.month, from: yearMonth)
        let day: Int = seasonString.suffix(1) == "0" ? 1 : 16
        let dateComponents = DateComponents(year: year, month: month, day: day)
        return Calendar.gregorian.date(from: dateComponents)!
    }

    func describe() -> String {
        let seasonString = String(self)
//        let formatter = DateFormatter.GregorianPOSIX()
//        formatter.dateFormat = "yyyyMM"
//        let yearMonth = formatter.date(from: String(seasonString.prefix(6)))!
//        let year = Calendar.gregorian.component(.year, from: yearMonth)
//        let month = Calendar.gregorian.component(.month, from: yearMonth)
        let half = {
            if String(seasonString.suffix(1)) == "0" {
                "abyssRankKit.rank.season.1".i18nAbyssRank
            } else {
                "abyssRankKit.rank.season.2".i18nAbyssRank
            }
        }()
        let yearStr = String(seasonString.prefix(6).prefix(4))
        guard let monthNum = Int(seasonString.prefix(6).suffix(2)) else {
            return ""
        }
        let monthStr = String(describing: monthNum)
        return yearStr + " " + monthStr + "abyssRankKit.rank.season.unit".i18nAbyssRank + half
    }

    static func choices(
        pvp: Bool = false,
        from date: Date = Date()
    )
        -> [AbyssSeason] {
        var choices = [Self]()
        var date = date
        var startDate = Calendar.gregorian
            .date(from: DateComponents(year: 2022, month: 11, day: 1))!
        if pvp {
            startDate = Calendar.gregorian
                .date(from: DateComponents(year: 2023, month: 4, day: 1))!
        }
        // 以下仅判断本月
        if Calendar.gregorian.dateComponents([.day], from: date).day! >= 16 {
            choices.append(date.yyyyMM() * 10 + 1)
        }
        choices.append(date.yyyyMM() * 10)
        date = Calendar.gregorian.date(byAdding: .month, value: -1, to: date)!
        while date >= startDate {
            choices.append(date.yyyyMM() * 10 + 1)
            choices.append(date.yyyyMM() * 10)
            date = Calendar.gregorian.date(byAdding: .month, value: -1, to: date)!
        }
        return choices
    }
}
