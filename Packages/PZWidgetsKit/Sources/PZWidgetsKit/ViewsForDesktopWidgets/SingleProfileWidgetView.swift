// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct SingleProfileWidgetView: View {
        // MARK: Lifecycle

        public init(entry: ProfileWidgetEntry, noBackground: Bool) {
            self.entry = entry
            self.noBackground = noBackground
        }

        // MARK: Public

        public var body: some View {
            ZStack {
                switch result {
                case let .success(dailyNote):
                    SingleProfileWidgetViewCore(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig
                    )
                case let .failure(error):
                    WidgetErrorView(
                        error: error,
                        message: viewConfig.noticeMessage ?? "",
                        refreshIntent: WidgetRefreshIntent(
                            dailyNoteUIDWithGame: entry.profile?.uidWithGame
                        )
                    )
                }
            }
            .environment(\.colorScheme, .dark)
            .pzWidgetContainerBackground(viewConfig: noBackground ? nil : viewConfig)
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var family: WidgetFamily

        private let entry: ProfileWidgetEntry
        private let noBackground: Bool

        private var result: Result<any DailyNoteProtocol, any Error> { entry.result }
        private var viewConfig: WidgetViewConfig { entry.viewConfig }
    }

    // MARK: - SingleProfileWidgetViewCore

    @available(watchOS, unavailable)
    struct SingleProfileWidgetViewCore: View {
        let entry: ProfileWidgetEntry
        @Environment(\.widgetFamily) var family: WidgetFamily
        var dailyNote: any DailyNoteProtocol
        let viewConfig: WidgetViewConfig

        var body: some View {
            Group {
                switch family {
                case .systemSmall:
                    MainInfo(
                        entry: entry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig
                    )
                case .systemMedium:
                    switch viewConfig.showStaminaOnly {
                    case true:
                        MainInfo(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    case false:
                        switch viewConfig.expeditionDisplayPolicy {
                        case .displayExclusively where hasExpeditionInfoForDisplay:
                            MainInfoWithExpedition(
                                entry: entry,
                                dailyNote: dailyNote,
                                viewConfig: viewConfig
                            )
                        default:
                            MainInfoWithDetail(
                                entry: entry,
                                dailyNote: dailyNote,
                                viewConfig: viewConfig
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
                                viewConfig: viewConfig
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        case true:
                            MainInfo(
                                entry: entry,
                                dailyNote: dailyNote,
                                viewConfig: viewConfig
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                    case false:
                        LargeWidgetView4SingleProfile(
                            entry: entry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
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
}
