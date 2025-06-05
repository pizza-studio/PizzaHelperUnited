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
            OfficialFeedWidgetView(
                entry: entry,
                showLeadingBorder: true
            )
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

    init(
        entry: OfficialFeedWidgetProvider.Entry,
        showLeadingBorder: Bool = true
    ) {
        self.entry = entry
        self.games = entry.games
        self.showLeadingBorder = showLeadingBorder
    }

    // MARK: Internal

    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
        OfficialFeedList4WidgetsView(
            events: entry?.events,
            showLeadingBorder: showLeadingBorder
        )
        .environment(\.colorScheme, .dark)
        .myWidgetContainerBackground(withPadding: 0) {
            WidgetBackgroundView(
                background: .randomNamecardBackground4Games(games),
                darkModeOn: true
            )
        }
    }

    // MARK: Private

    private let entry: OfficialFeedWidgetProvider.Entry?
    private let games: Set<Pizza.SupportedGame>
    private let showLeadingBorder: Bool
}
