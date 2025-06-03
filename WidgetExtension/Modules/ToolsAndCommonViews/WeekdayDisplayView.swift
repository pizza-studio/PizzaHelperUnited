// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZWidgetsKit
import SwiftUI

@available(watchOS, unavailable)
struct WeekdayDisplayView: View {
    // MARK: Internal

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text(dayOfMonth)
                .font(.system(
                    size: 35,
                    weight: .regular,
                    design: .rounded
                ))
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
            Text(weekday)
                .font(.caption)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.calendarWeekday.suiColor)
                .bold()
        }
        .legibilityShadow()
    }

    // MARK: Private

    private var weekday: String {
        let formatter = DateFormatter.CurrentLocale()
        formatter.dateFormat = "E" // Shortened weekday format
        formatter.locale = Locale.current // Use the system's current locale
        return formatter.string(from: Date())
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter.CurrentLocale()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
}
