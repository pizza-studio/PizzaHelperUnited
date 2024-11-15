// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
struct WidgetMainView: View {
    let entry: any TimelineEntry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        let profileName = viewConfig.showAccountName ? accountName : nil
        let defaultValue = MainInfoWithDetail(
            entry: entry,
            dailyNote: dailyNote,
            viewConfig: viewConfig,
            accountName: profileName
        )
        switch family {
        case .systemSmall:
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: profileName
            )
            .padding()
        case .systemMedium:
            defaultValue
        case .systemLarge:
            LargeWidgetView(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: profileName
            )
        default:
            defaultValue
        }
    }
}
