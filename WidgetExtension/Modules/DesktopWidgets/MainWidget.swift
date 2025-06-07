// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - MainWidget

@available(watchOS, unavailable)
struct MainWidget: Widget {
    let kind: String = "WidgetView"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectAccountIntent.self,
            provider: MainWidgetProvider()
        ) { entry in
            WidgetViewEntryView(entry: entry, noBackground: false)
        }
        .configurationDisplayName("pzWidgetsKit.status.title".i18nWidgets)
        .description("pzWidgetsKit.status.enquiry.title".i18nWidgets)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable(false)
    }
}

// MARK: - WidgetViewEntryView

@available(watchOS, unavailable)
struct WidgetViewEntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let entry: MainWidgetProvider.Entry
    let noBackground: Bool

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var viewConfig: WidgetViewConfig { entry.viewConfig }
    var accountName: String? { entry.profile?.name }

    var body: some View {
        ZStack {
            switch result {
            case let .success(dailyNote):
                WidgetMainView(
                    entry: entry,
                    dailyNote: dailyNote,
                    viewConfig: viewConfig,
                    accountName: accountName
                )
            case let .failure(error):
                WidgetErrorView(
                    error: error,
                    message: viewConfig.noticeMessage ?? "",
                    refreshIntent: WidgetRefreshIntent(
                        dailyNoteUIDWithGame: entry.profile?.uidWithGame
                    )
                )
            }
        }
        .environment(\.colorScheme, .dark)
        .pzWidgetContainerBackground(viewConfig: noBackground ? nil : viewConfig)
    }
}
