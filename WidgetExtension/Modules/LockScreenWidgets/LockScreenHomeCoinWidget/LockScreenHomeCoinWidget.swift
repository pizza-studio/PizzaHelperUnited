// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidget

@available(macOS, unavailable)
struct LockScreenHomeCoinWidget: Widget {
    let kind: String = "LockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(
                games: [.genshinImpact],
                recommendationsTag: "watch.info.RealmCurrency"
            )
        ) { entry in
            LockScreenHomeCoinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.homeCoin".i18nWidgets)
        .description("pzWidgetsKit.cfgName.homeCoin".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryCorner,
                .accessoryRectangular,
            ])
        #else
            .supportedFamilies([.accessoryCircular, .accessoryRectangular])
        #endif
    }
}

// MARK: - LockScreenHomeCoinWidgetView

@available(macOS, unavailable)
struct LockScreenHomeCoinWidgetView: View {
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
        Group {
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenHomeCoinWidgetCorner(entry: entry, result: result)
            #endif
            case .accessoryCircular:
                LockScreenHomeCoinWidgetCircular(entry: entry, result: result)
            case .accessoryRectangular:
                LockScreenHomeCoinWidgetRectangular(entry: entry, result: result)
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }
}
