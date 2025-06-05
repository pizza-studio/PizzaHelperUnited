// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

@available(watchOS, unavailable)
struct LargeWidgetView: View {
    // MARK: Lifecycle

    public init(
        entry: MainWidgetProvider.Entry,
        dailyNote: any DailyNoteProtocol,
        viewConfig: WidgetViewConfiguration,
        accountName: String?,
        events: [EventModel]
    ) {
        self.entry = entry
        self.dailyNote = dailyNote
        self.viewConfig = viewConfig
        self.accountName = accountName
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

    private let entry: MainWidgetProvider.Entry
    private let dailyNote: any DailyNoteProtocol
    private let viewConfig: WidgetViewConfiguration
    private let accountName: String?
    private let events: [EventModel]
}

// MARK: - View used when Tiny Glass Display Style is OFF.

@available(watchOS, unavailable)
extension LargeWidgetView {
    @ViewBuilder private var viewWhenTinyGlassModeIsOff: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                ProfileAndMainStaminaView(
                    profile: entry.profile,
                    dailyNote: dailyNote,
                    tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
                    verticalSpacing4NonTinyGlassMode: 5,
                    useSpacer: false,
                    refreshIntent: WidgetRefreshIntent(
                        dailyNoteUIDWithGame: entry.profile?.uidWithGame
                    )
                )
                Spacer(minLength: 18)
                switch viewConfig.prioritizeExpeditionDisplay {
                case true where hasExpeditionInfoForDisplay:
                    ExpeditionsView(
                        layout: .tinyWithShrinkedIconSpaces,
                        max4AllowedToDisplay: false,
                        expeditions: dailyNote.expeditionTasks,
                        pilotAssetMap: entry.pilotAssetMap
                    )
                    .frame(width: 160)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: dailyNote.game == .starRail ? -4 : -5)
                default:
                    DetailInfo(entry: entry, dailyNote: dailyNote, viewConfig: viewConfig, spacing: 17)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if hasExpeditionInfoForDisplay {
                Spacer()
                VStack(alignment: .leading) {
                    ExpeditionsView(
                        expeditions: dailyNote.expeditionTasks,
                        pilotAssetMap: entry.pilotAssetMap
                    )
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

// MARK: - View used when Tiny Glass Display Style is ON.

@available(watchOS, unavailable)
extension LargeWidgetView {
    @ViewBuilder private var viewWhenTinyGlassModeIsON: some View {
        let mainInfoView = ProfileAndMainStaminaView(
            profile: entry.profile,
            dailyNote: dailyNote,
            tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
            verticalSpacing4NonTinyGlassMode: 5,
            useSpacer: false,
            refreshIntent: WidgetRefreshIntent(
                dailyNoteUIDWithGame: entry.profile?.uidWithGame
            )
        )

        Grid {
            GridRow {
                HStack {
                    VStack(alignment: .leading) {
                        mainInfoView.profileNameLabel
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        Spacer()
                        Group {
                            switch viewConfig.prioritizeExpeditionDisplay {
                            case true where hasExpeditionInfoForDisplay:
                                ExpeditionsView(
                                    layout: .tinyWithShrinkedIconSpaces,
                                    max4AllowedToDisplay: false,
                                    expeditions: dailyNote.expeditionTasks,
                                    pilotAssetMap: entry.pilotAssetMap
                                )
                                .padding(.vertical, 8)
                                .padding(.leading, 4)
                                .padding(.trailing, 12)
                                .frame(width: dailyNote.game == .starRail ? 155 : 145)
                            default:
                                DetailInfo(
                                    entry: entry,
                                    dailyNote: dailyNote,
                                    viewConfig: viewConfig,
                                    spacing: 6
                                )
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.vertical, 8)
                                .padding(.leading, 8)
                            }
                        }
                        .widgetAccessibilityBackground(enabled: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    VStack(alignment: .trailing) {
                        if hasExpeditionInfoForDisplay {
                            ExpeditionsView(
                                layout: .tinyWithShrinkedIconSpaces,
                                max4AllowedToDisplay: false,
                                expeditions: dailyNote.expeditionTasks,
                                pilotAssetMap: entry.pilotAssetMap
                            )
                            .padding(.vertical, 8)
                            .padding(.leading, 4)
                            .padding(.trailing, 12)
                            .frame(width: dailyNote.game == .starRail ? 155 : 145)
                            .widgetAccessibilityBackground(enabled: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        }
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
}

// MARK: - Peripherals.

@available(watchOS, unavailable)
extension LargeWidgetView {
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
        /// 绝区零没有探索派遣。
        dailyNote.game != .zenlessZone && !viewConfig.prioritizeExpeditionDisplay
    }

    private var hasGIMaterialForDisplay: Bool {
        viewConfig.showMaterialsInLargeSizeWidget && dailyNote.game == .genshinImpact
    }
}
