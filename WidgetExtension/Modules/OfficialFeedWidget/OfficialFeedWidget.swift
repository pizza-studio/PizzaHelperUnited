// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - OfficialFeedWidget

@available(watchOS, unavailable)
struct OfficialFeedWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "OfficialFeedWidget",
            intent: SelectOnlyGameIntent.self,
            provider: OfficialFeedWidgetProvider()
        ) { entry in
            OfficialFeedWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.officialFeed.title".i18nWidgets)
        .description("pzWidgetsKit.officialFeed.description".i18nWidgets)
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable(false)
    }
}

// MARK: - OfficialFeedWidgetView

@available(watchOS, unavailable)
struct OfficialFeedWidgetView: View {
    // MARK: Lifecycle

    init(entry: OfficialFeedWidgetProvider.Entry?, isEmbedded: Bool = false) {
        self.entry = entry
        self.game = entry?.game
        self.isEmbedded = isEmbedded
    }

    // MARK: Internal

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        if isEmbedded {
            coreComponentEmbeddable()
        } else {
            coreComponentEmbeddable()
                .myWidgetContainerBackground(withPadding: 0) {
                    WidgetBackgroundView(
                        background: .randomNamecardBackground4Game(game),
                        darkModeOn: true
                    )
                }
        }
    }

    func getEvents(_ prefix: Int) -> [EventModel] {
        let filtered = events
            .filter { $0.endAtDate.timeIntervalSince1970 >= Date.now.timeIntervalSince1970 }
            .sorted { $0.endAtDate.timeIntervalSince1970 < $1.endAtDate.timeIntervalSince1970 }
            .prefix(prefix)
        return .init(filtered)
    }

    // MARK: Private

    private let entry: OfficialFeedWidgetProvider.Entry?
    private let game: Pizza.SupportedGame?
    private let isEmbedded: Bool

    private var entriesCountAppliable: [Int] {
        switch family {
        case .systemSmall: Array(4 ... 5).reversed()
        case .systemMedium: Array(4 ... 12).reversed()
        case .systemLarge: Array(4 ... 15).reversed()
        case .systemExtraLarge: Array(4 ... 25).reversed()
        default: Array(4 ... 5).reversed()
        }
    }

    private var events: [EventModel] {
        entry?.events ?? []
    }

    @ViewBuilder
    private func coreComponentEmbeddable() -> some View {
        if events.isEmpty {
            Button(intent: WidgetRefreshIntent()) {
                Image(systemSymbol: .arrowClockwiseCircle)
                    .font(.title3)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
            .foregroundColor(Color("textColor3", bundle: .main))
        }
        let leadingPadding: CGFloat? = isEmbedded ? nil : 7
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
            if !isEmbedded {
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .offset(x: 1)
            }
        }
        .legibilityShadow(isText: true)
        .foregroundColor(Color("textColor3", bundle: .main))
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
}
