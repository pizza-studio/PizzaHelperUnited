// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
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
    var viewConfig: Config4DesktopProfileWidgets { entry.viewConfig }

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
        .myContainerBackground(viewConfig: viewConfig)
    }

    @ViewBuilder var contents: some View {
        if !viewConfig.useTinyGlassDisplayStyle { Spacer(minLength: 0) }
        drawSingleEntry(subEntry1)
        Spacer(minLength: 15)
        drawSingleEntry(subEntry2)
        if !viewConfig.useTinyGlassDisplayStyle { Spacer(minLength: 0) }
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
    private func drawSingleEntry(_ givenEntry: MainWidgetProvider.Entry) -> some View {
        Group {
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
                // case .systemLarge, .systemExtraLarge:
                default:
                    switch viewConfig.expeditionDisplayPolicy {
                    case .neverDisplay:
                        Color.clear
                    case .displayWhenAvailable:
                        MainInfoWithDetail(
                            entry: givenEntry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
                    case .displayExclusively:
                        MainInfoWithExpedition(
                            entry: givenEntry,
                            dailyNote: dailyNote,
                            viewConfig: viewConfig,
                            accountName: profileName
                        )
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

@available(watchOS, unavailable)
extension View {
    @ViewBuilder
    fileprivate func myContainerBackground(
        viewConfig: Config4DesktopProfileWidgets?
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
        viewConfig: Config4DesktopProfileWidgets
    )
        -> some View {
        modifier(ContainerBackgroundStandbyDetector(viewConfig: viewConfig))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier: ViewModifier {
    var viewConfig: Config4DesktopProfileWidgets

    func body(content: Content) -> some View {
        content.containerBackgroundStandbyDetector(viewConfig: viewConfig)
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(watchOS, unavailable)
private struct ContainerBackgroundStandbyDetector: ViewModifier {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetContentMargins) var widgetContentMargins: EdgeInsets

    var viewConfig: Config4DesktopProfileWidgets

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
