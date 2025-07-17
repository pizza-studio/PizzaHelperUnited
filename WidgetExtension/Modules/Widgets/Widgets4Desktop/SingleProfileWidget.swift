// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - SingleProfileWidget

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
struct SingleProfileWidget: Widget {
    let kind: String = "WidgetView"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SingleProfileWidgetProvider.Intent.self,
            provider: SingleProfileWidgetProvider()
        ) { entry in
            DesktopWidgets
                .SingleProfileWidgetView(entry: entry, noBackground: false)
        }
        .configurationDisplayName("pzWidgetsKit.status.title".i18nWidgets)
        .description("pzWidgetsKit.status.enquiry.title".i18nWidgets)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable(false)
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct INSingleProfileWidget: Widget {
    let kind: String = "WidgetView".asBackportedWidgetKindName

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INSingleProfileWidgetProvider.Intent.self,
            provider: INSingleProfileWidgetProvider()
        ) { entry in
            DesktopWidgets
                .SingleProfileWidgetView(entry: entry, noBackground: false)
        }
        .configurationDisplayName("pzWidgetsKit.status.title".i18nWidgets)
        .description("pzWidgetsKit.status.enquiry.title".i18nWidgets)
        .supportedFamilies(
            [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge].backportsOnly
        )
        .containerBackgroundRemovable(false)
    }
}

#endif
