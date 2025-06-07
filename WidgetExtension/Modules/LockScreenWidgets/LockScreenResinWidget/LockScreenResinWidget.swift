// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidget

@available(macOS, unavailable)
struct LockScreenResinWidget: Widget {
    let kind: String = "LockScreenResinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            LockScreenResinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCorner,
            ])
        #else
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
            ])
        #endif
    }
}

// MARK: - LockScreenResinWidgetView

@available(macOS, unavailable)
public struct LockScreenResinWidgetView: View {
    // MARK: Lifecycle

    public init(entry: ProfileWidgetEntry) {
        self.entry = entry
    }

    // MARK: Public

    public let entry: ProfileWidgetEntry

    public var body: some View {
        Group {
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenResinWidgetCorner(entry: entry, result: result)
            #endif
            case .accessoryCircular:
                LockScreenResinWidgetCircular(entry: entry, result: result)
            case .accessoryRectangular:
                LockScreenResinWidgetRectangular(entry: entry, result: result)
            case .accessoryInline:
                LockScreenResinWidgetInline(entry: entry, result: result)
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
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
