// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - DualProfileWidget

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
struct DualProfileWidget: Widget {
    let kind: String = "DualProfileWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectDualProfileIntent.self,
            provider: DualProfileWidgetProvider()
        ) { entry in
            DesktopWidgets
                .DualProfileWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.statusDualProfile.title".i18nWidgets)
        .description("pzWidgetsKit.statusDualProfile.enquiry.title".i18nWidgets)
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable(false)
    }
}

#endif
