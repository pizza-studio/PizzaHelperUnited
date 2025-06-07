// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenExpeditionWidget

@available(macOS, unavailable)
struct LockScreenExpeditionWidget: Widget {
    let kind: String = "LockScreenExpeditionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(
                games: [.genshinImpact, .starRail],
                recommendationsTag: "watch.info.expedition"
            )
        ) { entry in
            LockScreenExpeditionWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.expedition".i18nWidgets)
        .description("pzWidgetsKit.cfgName.expedition".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenExpeditionWidgetView

@available(macOS, unavailable)
struct LockScreenExpeditionWidgetView: View {
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
                LockScreenExpeditionWidgetCorner(result: result)
            #endif
            case .accessoryCircular:
                LockScreenExpeditionWidgetCircular(result: result)
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }
}
