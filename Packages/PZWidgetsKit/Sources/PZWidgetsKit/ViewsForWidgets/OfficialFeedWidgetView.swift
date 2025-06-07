// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit
import SwiftUI

// MARK: - OfficialFeedWidgetView

@available(watchOS, unavailable)
public struct OfficialFeedWidgetView<RefreshIntent: AppIntent>: View {
    // MARK: Lifecycle

    public init(
        entry: OfficialFeedWidgetEntry,
        showLeadingBorder: Bool = true,
        refreshIntent: RefreshIntent?
    ) {
        self.entry = entry
        self.games = entry.games
        self.showLeadingBorder = showLeadingBorder
        self.refreshIntent = refreshIntent
    }

    // MARK: Public

    public var body: some View {
        OfficialFeedList4WidgetsView(
            events: entry.events,
            showLeadingBorder: showLeadingBorder,
            refreshIntent: refreshIntent
        )
        .environment(\.colorScheme, .dark)
        .pzWidgetContainerBackground(viewConfig: viewConfig)
    }

    // MARK: Private

    private let entry: OfficialFeedWidgetEntry
    private let games: Set<Pizza.SupportedGame>
    private let showLeadingBorder: Bool
    private let refreshIntent: RefreshIntent?

    private var viewConfig: WidgetViewConfig {
        var result = WidgetViewConfig()
        result.randomBackground = false
        result.selectedBackgrounds = [
            WidgetBackground.randomNamecardBackground4Games(entry.games),
        ]
        result.isDarkModeRespected = true
        return result
    }
}
