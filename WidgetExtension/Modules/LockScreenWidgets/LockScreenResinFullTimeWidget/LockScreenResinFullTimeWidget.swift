// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinFullTimeWidget

@available(macOS, unavailable)
struct LockScreenResinFullTimeWidget: Widget {
    let kind: String = "LockScreenResinFullTimeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.ofSb")
        ) { entry in
            LockScreenResinFullTimeWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.show.title".i18nWidgets)
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabled()
    }
}

// MARK: - LockScreenResinFullTimeWidgetView

@available(macOS, unavailable)
struct LockScreenResinFullTimeWidgetView: View {
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
            LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
        }
        .widgetURL(url)
    }
}
