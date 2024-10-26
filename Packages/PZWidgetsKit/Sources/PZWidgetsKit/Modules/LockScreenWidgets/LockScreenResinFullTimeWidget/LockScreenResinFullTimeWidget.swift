// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinFullTimeWidget

struct LockScreenResinFullTimeWidget: Widget {
    let kind: String = "LockScreenResinFullTimeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "widget.resin.refillTime.ofSb")
        ) { entry in
            LockScreenResinFullTimeWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("widget.resin.refillTime.title")
        .description("widget.resin.refillTime.show.title")
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabled()
    }
}

// MARK: - LockScreenResinFullTimeWidgetView

struct LockScreenResinFullTimeWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry

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

    @MainActor var body: some View {
        Group {
            LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
        }
        .widgetURL(url)
    }
}
