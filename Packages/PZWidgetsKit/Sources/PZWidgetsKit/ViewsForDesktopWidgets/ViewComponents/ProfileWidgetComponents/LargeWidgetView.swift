// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI
import WidgetKit

// MARK: - DesktopWidgets.LargeWidgetView4SingleProfile

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    struct LargeWidgetView4SingleProfile: View {
        // MARK: Lifecycle

        public init(
            entry: ProfileWidgetEntry,
            dailyNote: any DailyNoteProtocol,
            viewConfig: WidgetViewConfig,
            events: [OfficialFeed.FeedEvent]
        ) {
            self.entry = entry
            self.dailyNote = dailyNote
            self.viewConfig = viewConfig
            self.events = events
        }

        // MARK: Public

        public var body: some View {
            switch viewConfig.useTinyGlassDisplayStyle {
            case false: viewWhenTinyGlassModeIsOff
            case true: viewWhenTinyGlassModeIsON
            }
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var family: WidgetFamily

        private let entry: ProfileWidgetEntry
        private let dailyNote: any DailyNoteProtocol
        private let viewConfig: WidgetViewConfig
        private let events: [OfficialFeed.FeedEvent]

        private var weekday: String {
            let formatter = DateFormatter.CurrentLocale()
            formatter.dateFormat = "E" // Shortened weekday format
            formatter.locale = Locale.current // Use the system's current locale
            return formatter.string(from: Date())
        }

        private var dayOfMonth: String {
            let formatter = DateFormatter.CurrentLocale()
            formatter.dateFormat = "d"
            return formatter.string(from: Date())
        }

        private var hasExpeditionInfoForDisplay: Bool {
            /// 绝区零没有探索派遣，星穹铁道 API 也没有探索派遣。
            switch dailyNote.game {
            case .genshinImpact: !dailyNote.expeditionTasks.isEmpty
            case .starRail: false
            case .zenlessZone: false
            }
        }

        private var hasGIMaterialForDisplay: Bool {
            viewConfig.showMaterialsInLargeSizeWidget && dailyNote.game == .genshinImpact
        }

        @ViewBuilder private var viewWhenTinyGlassModeIsON: some View {
            let mainInfoView = ProfileAndMainStaminaView(
                profile: entry.profile,
                dailyNote: dailyNote,
                tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
                verticalSpacing4NonTinyGlassMode: 5,
                useSpacer: false
            )

            Grid {
                GridRow {
                    HStack {
                        VStack(alignment: .leading) {
                            mainInfoView.profileNameLabel
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            Spacer()
                            Group {
                                switch viewConfig.expeditionDisplayPolicy {
                                case .displayExclusively where hasExpeditionInfoForDisplay:
                                    ExpeditionsView(
                                        layout: .tinyWithShrinkedIconSpaces,
                                        limitPilotsIfNeeded: false,
                                        expeditions: dailyNote.expeditionTasks,
                                        pilotAssetMap: entry.pilotAssetMap
                                    )
                                    .padding(.vertical, 8)
                                    .padding(.leading, 4)
                                    .padding(.trailing, 12)
                                    .frame(width: dailyNote.game == .starRail ? 155 : 145)
                                default:
                                    MetaBlockView4Desktop(
                                        dailyNote: dailyNote,
                                        viewConfig: viewConfig,
                                        spacing: 6
                                    )
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 8)
                                    .padding(.trailing)
                                }
                            }
                            .widgetAccessibilityBackground(enabled: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        VStack(alignment: .trailing) {
                            Group {
                                switch viewConfig.expeditionDisplayPolicy {
                                case .displayWhenAvailable where hasExpeditionInfoForDisplay:
                                    ExpeditionsView(
                                        layout: .tinyWithShrinkedIconSpaces,
                                        limitPilotsIfNeeded: false,
                                        expeditions: dailyNote.expeditionTasks,
                                        pilotAssetMap: entry.pilotAssetMap
                                    )
                                    .padding(.vertical, 8)
                                    .padding(.leading, 4)
                                    .padding(.trailing, 12)
                                    .frame(width: dailyNote.game == .starRail ? 155 : 145)
                                default: EmptyView()
                                }
                            }
                            .widgetAccessibilityBackground(enabled: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .gridCellAnchor(.topLeading)

                    if family == .systemExtraLarge {
                        OfficialFeedList4WidgetsView(
                            events: entry.events,
                            showLeadingBorder: false
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .widgetAccessibilityBackground(enabled: viewConfig.useTinyGlassDisplayStyle)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .gridCellAnchor(.topTrailing)
                    }
                }
                GridRow {
                    mainInfoView.staminaLabelCompact
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                        .overlay(alignment: .bottomTrailing) {
                            if hasGIMaterialForDisplay {
                                MaterialView()
                                    .frame(maxWidth: 100)
                            }
                        }
                        .gridCellAnchor(.bottomLeading)
                    if family == .systemExtraLarge {
                        WeekdayDisplayView()
                            .padding(.horizontal, 10)
                            .widgetAccessibilityBackground(enabled: viewConfig.useTinyGlassDisplayStyle)
                            .gridCellAnchor(.bottomTrailing)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        @ViewBuilder private var viewWhenTinyGlassModeIsOff: some View {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    ProfileAndMainStaminaView(
                        profile: entry.profile,
                        dailyNote: dailyNote,
                        tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
                        verticalSpacing4NonTinyGlassMode: 5,
                        useSpacer: false
                    )
                    Spacer(minLength: 18)
                    switch viewConfig.expeditionDisplayPolicy {
                    case .displayExclusively where hasExpeditionInfoForDisplay:
                        ExpeditionsView(
                            layout: .tinyWithShrinkedIconSpaces,
                            limitPilotsIfNeeded: false,
                            expeditions: dailyNote.expeditionTasks,
                            pilotAssetMap: entry.pilotAssetMap
                        )
                        .frame(width: 160)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: dailyNote.game == .starRail ? -4 : -5)
                    default:
                        MetaBlockView4Desktop(
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            spacing: 17
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Group {
                    Spacer()
                    VStack(alignment: .leading) {
                        switch viewConfig.expeditionDisplayPolicy {
                        case .displayWhenAvailable where hasExpeditionInfoForDisplay:
                            ExpeditionsView(
                                expeditions: dailyNote.expeditionTasks,
                                pilotAssetMap: entry.pilotAssetMap
                            )
                        default: EmptyView()
                        }
                        Spacer(minLength: 15)
                        if hasGIMaterialForDisplay {
                            MaterialView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                if family == .systemExtraLarge {
                    trailingPaneForNonGlassViewMode()
                        .frame(width: 300)
                }
                Spacer()
            }
        }

        @ViewBuilder
        private func trailingPaneForNonGlassViewMode() -> some View {
            VStack(alignment: .trailing) {
                OfficialFeedList4WidgetsView(
                    events: entry.events,
                    showLeadingBorder: false
                )
                .padding(.leading, 20)
                .widgetAccessibilityBackground(enabled: viewConfig.useTinyGlassDisplayStyle)
                Spacer()
                WeekdayDisplayView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#endif
