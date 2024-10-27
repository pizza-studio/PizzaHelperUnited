// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI
import WidgetKit

struct WidgetMainView: View {
    let entry: any TimelineEntry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    @MainActor var body: some View {
        switch family {
        case .systemSmall:
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
            .padding()
        case .systemMedium:
            MainInfoWithDetail(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        case .systemLarge:
            LargeWidgetView(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        default:
            MainInfoWithDetail(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: viewConfig.showAccountName ? accountName : nil
            )
        }
    }
}
