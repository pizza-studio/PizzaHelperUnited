// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(watchOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
extension DesktopWidgets {
    public struct WeekdayDisplayView: View {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(dayOfMonth)
                    .font(.system(
                        size: 35,
                        weight: .regular,
                        design: .rounded
                    ))
                    .foregroundColor(.primary)
                Text(weekday)
                    .font(.caption)
                    .foregroundColor(.red)
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
}
