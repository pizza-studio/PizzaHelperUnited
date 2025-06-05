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
struct MainInfoWithExpedition: View {
    let entry: MainWidgetProvider.Entry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
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
            ExpeditionsView(
                layout: tinyGlass ? .tinyWithShrinkedIconSpaces : .tiny,
                max4AllowedToDisplay: true,
                expeditions: dailyNote.expeditionTasks,
                pilotAssetMap: entry.pilotAssetMap
            )
            .padding(.vertical, tinyGlass ? 8 : 0)
            .padding(.leading, tinyGlass ? 4 : 0)
            .padding(.trailing, tinyGlass ? 12 : 0)
            .frame(width: tinyGlass ? 150 : 160)
            .widgetAccessibilityBackground(enabled: tinyGlass)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
