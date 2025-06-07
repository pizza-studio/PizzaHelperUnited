// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - MainInfoWithDetail

@available(watchOS, unavailable)
struct MainInfoWithDetail: View {
    let entry: MainWidgetProvider.Entry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfig
    let accountName: String?

    var body: some View {
        let tinyGlass = viewConfig.useTinyGlassDisplayStyle
        HStack {
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            .frame(maxWidth: .infinity, alignment: tinyGlass ? .leading : .center)
            Group {
                switch tinyGlass {
                case false:
                    DetailInfo(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        spacing: 10
                    )
                    .fixedSize(horizontal: true, vertical: false)
                case true:
                    DetailInfo(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        spacing: 10
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.vertical, 8)
                    .padding(.leading, 8)
                    .widgetAccessibilityBackground(enabled: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: tinyGlass ? .trailing : .center)
        }
        .frame(maxWidth: tinyGlass ? nil : 300)
    }
}
