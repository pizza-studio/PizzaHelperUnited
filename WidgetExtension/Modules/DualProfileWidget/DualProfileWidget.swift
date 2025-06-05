// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - DualProfileWidget

@available(watchOS, unavailable)
struct DualProfileWidget: Widget {
    let kind: String = "DualProfileWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectDualProfileIntent.self,
            provider: DualProfileWidgetProvider()
        ) { entry in
            WidgetViewEntryView4DualProfileWidget(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.statusDualProfile.title".i18nWidgets)
        .description("pzWidgetsKit.statusDualProfile.enquiry.title".i18nWidgets)
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable(false)
    }
}

// MARK: - WidgetViewEntryView4DualProfileWidget

@available(watchOS, unavailable)
private struct WidgetViewEntryView4DualProfileWidget: View {
    // MARK: Internal

    @Environment(\.widgetFamily) var family: WidgetFamily

    let entry: DualProfileWidgetProvider.Entry

    var resultSlot1: Result<any DailyNoteProtocol, any Error> { entry.resultSlot1 }
    var resultSlot2: Result<any DailyNoteProtocol, any Error> { entry.resultSlot2 }
    var viewConfig: WidgetViewConfiguration { entry.viewConfig }

    var subEntry1: MainWidgetProvider.Entry {
        .init(
            date: entry.date,
            result: entry.resultSlot1,
            viewConfig: entry.viewConfig,
            profile: entry.profileSlot1,
            pilotAssetMap: entry.pilotAssetMap,
            events: entry.events.filter { $0.game == entry.profileSlot1?.game }
        )
    }

    var subEntry2: MainWidgetProvider.Entry {
        .init(
            date: entry.date,
            result: entry.resultSlot2,
            viewConfig: entry.viewConfig,
            profile: entry.profileSlot2,
            pilotAssetMap: entry.pilotAssetMap,
            events: entry.events.filter { $0.game == entry.profileSlot2?.game }
        )
    }

    var widgetFamilyForComponents: WidgetFamily {
        switch family {
        case .systemSmall: .systemSmall
        case .systemMedium: .systemSmall
        case .systemLarge: .systemMedium
        case .systemExtraLarge: .systemLarge
        default: family
        }
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                VStack { contents }
            case .systemMedium:
                HStack { contents }
            case .systemLarge:
                VStack { contents }
            case .systemExtraLarge:
                HStack {
                    VStack {
                        contents
                    }
                    if family == .systemExtraLarge {
                        officialFeedBlock()
                            .frame(width: 300)
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
        .myContainerBackground(viewConfig: viewConfig)
    }

    @ViewBuilder var contents: some View {
        drawSingleEntry(subEntry1)
        let divider = Divider().overlay {
            Color.white.opacity(0.4)
        }
        if !viewConfig.useTinyGlassDisplayStyle {
            switch family {
            case .systemSmall: EmptyView() // Small size not supported.
            case .systemMedium:
                divider
                    .frame(maxWidth: 4)
                    .padding()
                    .frame(maxWidth: 9)
            default:
                divider
                    .frame(maxHeight: 5)
                    .padding(.horizontal)
            }
        } else {
            switch family {
            case .systemSmall: EmptyView() // Small size not supported.
            case .systemMedium:
                EmptyView()
                    .frame(maxWidth: 1)
                    .padding()
                    .frame(maxWidth: 9)
            default:
                EmptyView()
                    .frame(maxHeight: 3)
            }
        }
        drawSingleEntry(subEntry2)
    }

    // MARK: Private

    @ViewBuilder
    private func officialFeedBlock() -> some View {
        VStack(alignment: .trailing) {
            let officialFeedList = OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: false
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
                    showLeadingBorder: false
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
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
    private func drawSingleEntry(_ givenEntry: MainWidgetProvider.Entry) -> some View {
        switch givenEntry.result {
        case let .success(dailyNote):
            let profileName = viewConfig.showAccountName ? givenEntry.profile?.name : nil
            switch family {
            case .systemMedium, .systemSmall:
                MainInfo(
                    entry: givenEntry,
                    dailyNote: dailyNote,
                    viewConfig: viewConfig,
                    accountName: profileName
                )
            // case .systemExtraLarge, .systemLarge:
            default:
                if viewConfig.prioritizeExpeditionDisplay, !dailyNote.expeditionTasks.isEmpty {
                    MainInfoWithExpedition(
                        entry: givenEntry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        accountName: profileName
                    )
                    .padding(.horizontal, viewConfig.useTinyGlassDisplayStyle ? 0 : nil)
                } else {
                    MainInfoWithDetail(
                        entry: givenEntry,
                        dailyNote: dailyNote,
                        viewConfig: viewConfig,
                        accountName: profileName
                    )
                    .padding(.horizontal, viewConfig.useTinyGlassDisplayStyle ? 0 : nil)
                }
            }
        case let .failure(error):
            WidgetErrorView(
                error: error,
                message: viewConfig.noticeMessage ?? ""
            )
        }
    }
}

@available(watchOS, unavailable)
extension View {
    @ViewBuilder
    fileprivate func myContainerBackground(
        viewConfig: WidgetViewConfiguration?
    )
        -> some View {
        if let viewConfig {
            modifier(ContainerBackgroundModifier(viewConfig: viewConfig))
        } else {
            self
        }
    }

    @ViewBuilder
    fileprivate func containerBackgroundStandbyDetector(
        viewConfig: WidgetViewConfiguration
    )
        -> some View {
        modifier(ContainerBackgroundStandbyDetector(viewConfig: viewConfig))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier: ViewModifier {
    var viewConfig: WidgetViewConfiguration

    func body(content: Content) -> some View {
        content.containerBackgroundStandbyDetector(viewConfig: viewConfig)
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(watchOS, unavailable)
private struct ContainerBackgroundStandbyDetector: ViewModifier {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetContentMargins) var widgetContentMargins: EdgeInsets

    var viewConfig: WidgetViewConfiguration

    func body(content: Content) -> some View {
        if widgetContentMargins.top < 5 {
            content.containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        } else {
            content.padding(-15).containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        }
    }
}
