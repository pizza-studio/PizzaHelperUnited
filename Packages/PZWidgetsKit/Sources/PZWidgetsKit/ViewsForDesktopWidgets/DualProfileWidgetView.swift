// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct DualProfileWidgetView: View {
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
                    HStack(spacing: 0) {
                        contents
                    }
                    .frame(maxWidth: .infinity)
                case .systemLarge:
                    VStack(spacing: 0) {
                        contents
                    }
                    .frame(maxWidth: .infinity)
                case .systemExtraLarge:
                    HStack {
                        VStack(spacing: 0) {
                            contents
                        }
                        .frame(maxWidth: .infinity)
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
            overlayDivider(isVertical: family != .systemMedium)
            drawSingleEntry(subEntry2)
            if !viewConfig.useTinyGlassDisplayStyle { Spacer(minLength: 0) }
        }

        @ViewBuilder
        private func officialFeedBlock() -> some View {
            VStack(alignment: .trailing) {
                let officialFeedList = OfficialFeedList4WidgetsView(
                    events: entry.events,
                    showLeadingBorder: false
                )
                switch viewConfig.useTinyGlassDisplayStyle {
                case false:
                    officialFeedList
                        .contentShape(.rect)
                        .padding(.leading, 14)
                    Spacer()
                    WeekdayDisplayView()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                case true:
                    officialFeedList
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
                        MainInfo(
                            entry: givenEntry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig
                        )
                    // case .systemLarge, .systemExtraLarge:
                    default:
                        switch viewConfig.expeditionDisplayPolicy {
                        case .neverDisplay:
                            MainInfoWithDetail(
                                entry: givenEntry,
                                dailyNote: dailyNote,
                                viewConfig: viewConfig
                            )
                        case .displayExclusively, .displayWhenAvailable:
                            switch dailyNote.game {
                            case .zenlessZone:
                                MainInfoWithDetail(
                                    entry: givenEntry,
                                    dailyNote: dailyNote,
                                    viewConfig: viewConfig
                                )
                            default:
                                switch dailyNote.expeditionTasks.isEmpty {
                                case true:
                                    MainInfoWithDetail(
                                        entry: givenEntry,
                                        dailyNote: dailyNote,
                                        viewConfig: viewConfig
                                    )
                                case false:
                                    MainInfoWithExpedition(
                                        entry: givenEntry,
                                        dailyNote: dailyNote,
                                        viewConfig: viewConfig
                                    )
                                }
                            }
                        }
                    }
                case let .failure(error):
                    WidgetErrorView(
                        error: error,
                        message: viewConfig.noticeMessage ?? "",
                        refreshIntent: WidgetRefreshIntent(
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
                .padding(isVertical ? .horizontal : .vertical)
                Color.clear
            }
            switch isVertical {
            case true: VStack {
                    dividerViewRAW
                        .frame(height: 1)
                }
            case false: HStack {
                    dividerViewRAW
                        .frame(width: 1)
                }
            }
        }
    }
}
