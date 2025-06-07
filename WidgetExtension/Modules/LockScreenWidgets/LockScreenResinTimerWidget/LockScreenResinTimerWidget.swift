// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
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
                .smartStackWidgetContainerBackground { EmptyView() }
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
public struct LockScreenResinTimerWidgetView: View {
    // MARK: Lifecycle

    public init(entry: ProfileWidgetEntry) {
        self.entry = entry
    }

    // MARK: Public

    public let entry: ProfileWidgetEntry

    public var body: some View {
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

    // MARK: Private

    @Environment(\.widgetFamily) private var family: WidgetFamily

    private var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    private var accountName: String? { entry.profile?.name }

    private var url: URL? {
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
}
