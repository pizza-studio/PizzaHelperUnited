// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
extension OfficialFeed.FeedEvent {
    @available(watchOS, unavailable)
    @MainActor @ViewBuilder
    public func textListItemRenderable() -> some View {
        HStack {
            Text(verbatim: " \(title)")
                .lineLimit(1)
            Spacer()
            let endAtIntel = endAtTime
            if let dayLeft = endAtIntel.day, dayLeft > 0 {
                Text(
                    "igev.gameEvents.daysLeft:\(dayLeft)",
                    bundle: .module
                )
            } else if let hoursLeft = endAtIntel.hour, hoursLeft > 0 {
                Text(
                    "igev.gameEvents.hoursLeft:\(hoursLeft)",
                    bundle: .module
                )
            }
        }
        .font(.caption)
        .foregroundColor(.primary)
    }

    public func textListItemRaw() -> (title: String, remainingDays: String) {
        let remainingDays: String = {
            let endAtIntel = endAtTime
            if let dayLeft = endAtIntel.day, dayLeft > 0 {
                return String(
                    localized:
                    "igev.gameEvents.daysLeft:\(dayLeft)",
                    bundle: .module
                )
            } else if let hoursLeft = endAtIntel.hour, hoursLeft > 0 {
                return String(
                    localized:
                    "igev.gameEvents.hoursLeft:\(hoursLeft)",
                    bundle: .module
                )
            } else {
                return endAt
            }
        }()
        return (title, remainingDays)
    }
}
