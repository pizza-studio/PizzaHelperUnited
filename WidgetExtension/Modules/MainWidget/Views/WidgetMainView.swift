// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
struct WidgetMainView: View {
    let entry: MainWidgetProvider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        let profileName = viewConfig.showAccountName ? accountName : nil
        Group {
            switch family {
            case .systemSmall:
                MainInfo(
                    entry: entry,
                    dailyNote: dailyNote,
                    viewConfig: viewConfig,
                    accountName: profileName
                )
            case .systemMedium:
                switch viewConfig.showStaminaOnly {
                case true:
                    MainInfo(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        accountName: profileName
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                case false:
                    switch viewConfig.expeditionDisplayPolicy {
                    case .displayExclusively where hasExpeditionInfoForDisplay:
                        MainInfoWithExpedition(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
                    default:
                        MainInfoWithDetail(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
                    }
                }
            case .systemExtraLarge, .systemLarge:
                switch viewConfig.showStaminaOnly {
                case true:
                    switch viewConfig.useTinyGlassDisplayStyle {
                    case false:
                        MainInfo(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    case true:
                        MainInfo(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                case false:
                    LargeWidgetView(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        accountName: profileName,
                        events: entry.events
                    )
                }
            default:
                Text(verbatim: "Layout not supported yet.")
            }
        }
        .padding()
    }

    private var hasExpeditionInfoForDisplay: Bool {
        /// 绝区零没有探索派遣。
        dailyNote.game != .zenlessZone && !dailyNote.expeditionTasks.isEmpty
    }
}
