// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - AlternativeLockScreenHomeCoinWidget

@available(macOS, unavailable)
struct AlternativeLockScreenHomeCoinWidget: Widget {
    let kind: String = "AlternativeLockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(
                games: [.genshinImpact],
                recommendationsTag: "watch.info.RealmCurrency"
            )
        ) { entry in
            AlternativeLockScreenHomeCoinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.homeCoin".i18nWidgets)
        .description("pzWidgetsKit.cfgName.homeCoin.2".i18nWidgets)
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - AlternativeLockScreenHomeCoinWidgetView

@available(macOS, unavailable)
struct AlternativeLockScreenHomeCoinWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let entry: LockScreenWidgetProvider.Entry

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.profile?.name }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.profile?.uuid.uuidString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }

    var body: some View {
        AlternativeLockScreenHomeCoinWidgetCircular(entry: entry, result: result)
            .widgetURL(url)
    }
}
