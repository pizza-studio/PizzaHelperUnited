// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZBaseKit
import SwiftUI

@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct OfficialFeedWidgetView: View {
        // MARK: Lifecycle

        public init(
            entry: OfficialFeedWidgetEntry,
            showLeadingBorder: Bool = true
        ) {
            self.entry = entry
            self.games = entry.games
            self.showLeadingBorder = showLeadingBorder
        }

        // MARK: Public

        public var body: some View {
            OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: showLeadingBorder
            )
            .environment(\.colorScheme, .dark)
            .pzWidgetContainerBackground(viewConfig: viewConfig)
        }

        // MARK: Private

        private let entry: OfficialFeedWidgetEntry
        private let games: Set<Pizza.SupportedGame>
        private let showLeadingBorder: Bool

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
}
