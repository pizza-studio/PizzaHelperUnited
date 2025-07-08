// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Foundation
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - MaterialWidget

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct MaterialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MaterialWidget",
            provider: MaterialWidgetProvider()
        ) { entry in
            DesktopWidgets.MaterialWidgetView(
                entry: entry
            )
        }
        .configurationDisplayName("pzWidgetsKit.material.title".i18nWidgets)
        .description("pzWidgetsKit.material.description".i18nWidgets)
        .supportedFamilies([.systemMedium])
        .containerBackgroundRemovable(false)
    }
}

#endif
