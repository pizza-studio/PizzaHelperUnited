// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
extension DesktopWidgets {
    struct MainInfoWithDetail: View {
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
                Group {
                    switch tinyGlass {
                    case false:
                        MetaBlockView4Desktop(
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            spacing: 10
                        )
                        .fixedSize(horizontal: true, vertical: false)
                    case true:
                        MetaBlockView4Desktop(
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            spacing: 10
                        )
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.vertical, 8)
                        .padding(.leading, 8)
                        .padding(.trailing)
                        .widgetAccessibilityBackground(enabled: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: tinyGlass ? .trailing : .center)
            }
            .frame(maxWidth: tinyGlass ? nil : 300)
        }
    }
}
