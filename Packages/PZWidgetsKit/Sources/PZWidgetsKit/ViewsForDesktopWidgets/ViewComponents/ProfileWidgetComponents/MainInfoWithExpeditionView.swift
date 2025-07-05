// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    struct MainInfoWithExpedition: View {
        let entry: ProfileWidgetEntry
        var dailyNote: any DailyNoteProtocol
        let viewConfig: WidgetViewConfig

        var body: some View {
            let tinyGlass = viewConfig.useTinyGlassDisplayStyle
            HStack {
                MainInfo(
                    entry: entry,
                    dailyNote: dailyNote,
                    viewConfig: viewConfig
                )
                .frame(maxWidth: .infinity, alignment: tinyGlass ? .leading : .center)
                ExpeditionsView(
                    layout: tinyGlass ? .tinyWithShrinkedIconSpaces : .tiny,
                    limitPilotsIfNeeded: true,
                    expeditions: dailyNote.expeditionTasks,
                    pilotAssetMap: entry.pilotAssetMap
                )
                .padding(.vertical, tinyGlass ? 8 : 0)
                .padding(.leading, tinyGlass ? 4 : 0)
                .padding(.trailing, tinyGlass ? 12 : 0)
                .frame(width: tinyGlass ? 140 : 150)
                .widgetAccessibilityBackground(enabled: tinyGlass)
                .frame(maxWidth: .infinity, alignment: tinyGlass ? .trailing : .center)
            }
            .frame(maxWidth: tinyGlass ? nil : 300)
        }
    }
}
