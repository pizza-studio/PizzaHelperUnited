// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - OfficialFeedList4WidgetsView

@available(watchOS, unavailable)
struct OfficialFeedList4WidgetsView: View {
    // MARK: Lifecycle

    init(
        events: [EventModel]?,
        showLeadingBorder: Bool
    ) {
        self.events = events ?? []
        self.showLeadingBorder = showLeadingBorder
    }

    // MARK: Internal

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        coreComponentEmbeddable()
    }

    // MARK: Private

    private let events: [EventModel]
    private let showLeadingBorder: Bool

    private var entriesCountAppliable: [Int] {
        switch family {
        case .systemSmall: Array(4 ... 5).reversed()
        case .systemMedium: Array(4 ... 12).reversed()
        case .systemExtraLarge, .systemLarge: Array(4 ... 15).reversed()
        default: Array(4 ... 5).reversed()
        }
    }

    @ViewBuilder
    private func coreComponentEmbeddable() -> some View {
        if events.isEmpty {
            Button(intent: WidgetRefreshIntent()) {
                Image(systemSymbol: .arrowClockwiseCircle)
                    .font(.title3)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
            .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
        }
        let leadingPadding: CGFloat? = !showLeadingBorder ? 0 : 7
        ViewThatFits(in: .vertical) {
            ForEach(entriesCountAppliable, id: \.self) { entriesCount in
                VStack(spacing: 7) {
                    ForEach(
                        getEvents(entriesCount),
                        id: \.id
                    ) { content in
                        eventItem(event: content)
                    }
                }
                VStack(spacing: 5) {
                    ForEach(
                        getEvents(entriesCount),
                        id: \.id
                    ) { content in
                        eventItem(event: content)
                    }
                }
            }
        }
        .padding(.leading, leadingPadding)
        .overlay(alignment: .leading) {
            if showLeadingBorder {
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .offset(x: 1)
            }
        }
        .legibilityShadow(isText: true)
        .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
    }

    @ViewBuilder
    private func eventItem(event: EventModel) -> some View {
        let line = event.textListItemRaw()
        HStack {
            Text(verbatim: " \(line.title)")
                .lineLimit(1)
            Spacer()
            Text(line.remainingDays)
                .allowsTightening(true)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .font(.caption)
        .fontWidth(.condensed)
    }

    private func getEvents(_ prefix: Int) -> [EventModel] {
        let filtered = events
            .filter { $0.endAtDate.timeIntervalSince1970 >= Date.now.timeIntervalSince1970 }
            .sorted { $0.endAtDate.timeIntervalSince1970 < $1.endAtDate.timeIntervalSince1970 }
            .prefix(prefix)
        return .init(filtered)
    }
}
