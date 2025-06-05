// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - MaterialWidget

@available(watchOS, unavailable)
struct MaterialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MaterialWidget",
            provider: MaterialWidgetProvider()
        ) { entry in
            MaterialWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.material.title".i18nWidgets)
        .description("pzWidgetsKit.material.description".i18nWidgets)
        .supportedFamilies([.systemMedium])
        .containerBackgroundRemovable(false)
    }
}

// MARK: - MaterialWidgetView

@available(watchOS, unavailable)
struct MaterialWidgetView: View {
    let entry: MaterialWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                WeekdayDisplayView()
                Spacer()
                ZStack(alignment: .trailing) {
                    if entry.materialWeekday != nil {
                        MaterialView(alternativeLayout: true)
                    } else {
                        Image(systemSymbol: .checkmarkCircleFill)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .legibilityShadow(isText: false)
                    }
                }
                .frame(height: 35)
            }
            .frame(height: 40)
            .padding(.bottom, 12)
            OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: true
            )
        }
        .environment(\.colorScheme, .dark)
        .myWidgetContainerBackground(withPadding: 0) {
            WidgetBackgroundView(
                background: .randomNamecardBackground4Game(.genshinImpact),
                darkModeOn: true
            )
        }
    }
}
