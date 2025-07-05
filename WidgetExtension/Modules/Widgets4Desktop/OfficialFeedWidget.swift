// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - OfficialFeedWidget

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
struct OfficialFeedWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "OfficialFeedWidget",
            intent: SelectOnlyGameIntent.self,
            provider: OfficialFeedWidgetProvider()
        ) { entry in
            DesktopWidgets.OfficialFeedWidgetView(
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
