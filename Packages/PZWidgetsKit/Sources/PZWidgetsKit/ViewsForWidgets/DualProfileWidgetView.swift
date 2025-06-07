// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - DualProfileWidgetView

@available(watchOS, unavailable)
public struct DualProfileWidgetView<RefreshIntent: WidgetRefreshIntentProtocol>: View {
    // MARK: Lifecycle

    public init(entry: ProfileWidgetEntry) {
        self.entry = entry
    }

    // MARK: Public

    public var body: some View {
        Group {
            switch family {
            case .systemSmall: EmptyView() // Not supported.
            case .systemMedium:
                HStack {
                    contents
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    overlayDivider(isVertical: false)
                }
            case .systemLarge:
                VStack {
                    contents
                }
                .frame(maxWidth: .infinity)
                .overlay {
                    overlayDivider(isVertical: true)
                }
            case .systemExtraLarge:
                HStack {
                    VStack {
                        contents
                    }
                    .frame(maxWidth: .infinity)
                    .overlay {
                        overlayDivider(isVertical: true)
                    }
                    if family == .systemExtraLarge {
                        officialFeedBlock()
                            .frame(maxWidth: 300)
                    }
                }
            case .accessoryCorner: EmptyView()
            case .accessoryCircular: EmptyView()
            case .accessoryRectangular: EmptyView()
            case .accessoryInline: EmptyView()
            @unknown default: EmptyView()
            }
        }
        .padding()
        .environment(\.colorScheme, .dark)
        .pzWidgetContainerBackground(viewConfig: viewConfig)
    }

    // MARK: Private

    @Environment(\.widgetFamily) private var family: WidgetFamily

    private let entry: ProfileWidgetEntry

    private var resultSlot1: Result<any DailyNoteProtocol, any Error> { entry.resultSlot1 }
    private var resultSlot2: Result<any DailyNoteProtocol, any Error> { entry.resultSlot2 }
    private var viewConfig: WidgetViewConfig { entry.viewConfig }

    private var subEntry1: ProfileWidgetEntry {
        .init(
            date: entry.date,
            result: entry.resultSlot1,
            viewConfig: entry.viewConfig,
            profile: entry.profileSlot1,
            pilotAssetMap: entry.pilotAssetMap,
            events: entry.events.filter { $0.game == entry.profileSlot1?.game }
        )
    }

    private var subEntry2: ProfileWidgetEntry {
        .init(
            date: entry.date,
            result: entry.resultSlot2,
            viewConfig: entry.viewConfig,
            profile: entry.profileSlot2,
            pilotAssetMap: entry.pilotAssetMap,
            events: entry.events.filter { $0.game == entry.profileSlot2?.game }
        )
    }

    private var widgetFamilyForComponents: WidgetFamily {
        switch family {
        case .systemSmall: .systemSmall
        case .systemMedium: .systemSmall
        case .systemLarge: .systemMedium
        case .systemExtraLarge: .systemLarge
        default: family
        }
    }

    @ViewBuilder private var contents: some View {
        if !viewConfig.useTinyGlassDisplayStyle { Spacer(minLength: 0) }
        drawSingleEntry(subEntry1)
        Spacer(minLength: 15)
        drawSingleEntry(subEntry2)
        if !viewConfig.useTinyGlassDisplayStyle { Spacer(minLength: 0) }
    }

    @ViewBuilder
    private func officialFeedBlock() -> some View {
        VStack(alignment: .trailing) {
            let officialFeedList = OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: false,
                refreshIntent: RefreshIntent(dailyNoteUIDWithGame: nil)
            )
            .contentShape(.rect)
            switch viewConfig.useTinyGlassDisplayStyle {
            case false:
                officialFeedList
                    .padding(.leading, 14)
                Spacer()
                WeekdayDisplayView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            case true:
                OfficialFeedList4WidgetsView(
                    events: entry.events,
                    showLeadingBorder: false,
                    refreshIntent: RefreshIntent(dailyNoteUIDWithGame: nil)
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .widgetAccessibilityBackground(enabled: viewConfig.useTinyGlassDisplayStyle)
                Spacer()
                WeekdayDisplayView()
                    .padding(.horizontal, 10)
                    .widgetAccessibilityBackground(enabled: viewConfig.useTinyGlassDisplayStyle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func drawSingleEntry(_ givenEntry: ProfileWidgetEntry) -> some View {
        Group {
            switch givenEntry.result {
            case let .success(dailyNote):
                switch family {
                case .systemMedium, .systemSmall:
                    MainInfo<RefreshIntent>(
                        entry: givenEntry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig
                    )
                // case .systemLarge, .systemExtraLarge:
                default:
                    switch viewConfig.expeditionDisplayPolicy {
                    case .neverDisplay:
                        Color.clear
                    case .displayWhenAvailable:
                        MainInfoWithDetail<RefreshIntent>(
                            entry: givenEntry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig
                        )
                    case .displayExclusively:
                        MainInfoWithExpedition<RefreshIntent>(
                            entry: givenEntry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig
                        )
                    }
                }
            case let .failure(error):
                WidgetErrorView(
                    error: error,
                    message: viewConfig.noticeMessage ?? "",
                    refreshIntent: RefreshIntent(
                        dailyNoteUIDWithGame: givenEntry.profile?.uidWithGame
                    )
                )
            }
        }
    }

    @ViewBuilder
    private func overlayDivider(isVertical: Bool) -> some View {
        let dividerViewRAW = Group {
            Color.clear
            Divider().overlay {
                Color.black
            }
            .blendMode(.colorDodge)
            .padding()
            Color.clear
        }
        switch isVertical {
        case true: VStack { dividerViewRAW }
        case false: HStack { dividerViewRAW }
        }
    }
}
