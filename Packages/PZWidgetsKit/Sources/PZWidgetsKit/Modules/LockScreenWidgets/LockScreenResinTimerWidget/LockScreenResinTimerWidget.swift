// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinTimerWidget

@available(macOS, unavailable)
struct LockScreenResinTimerWidget: Widget {
    let kind: String = "LockScreenResinTimerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.countdown.ofSb")
        ) { entry in
            LockScreenResinTimerWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.countdown.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.countdown.show.title".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCircular])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenResinTimerWidgetView

@available(macOS, unavailable)
struct LockScreenResinTimerWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry
    @MainActor var body: some View {
        switch family {
        case .accessoryCircular:
            Group {
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            }
            .widgetURL(url)
        #if os(watchOS)
        case .accessoryCorner:
            Group {
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            }
            .widgetURL(url)
        #endif
        default:
            EmptyView()
        }
    }

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
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
}
