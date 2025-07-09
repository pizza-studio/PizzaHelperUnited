// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS) && !targetEnvironment(macCatalyst)

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenResinWidget: Widget {
    let kind: String = "LockScreenResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            EmbeddedWidgets
                .LockScreenResinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
                .accessoryCorner,
            ].backportsOnly)
        #else
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
            ].backportsOnly)
        #endif
    }
}

// MARK: - AlternativeLockScreenHomeCoinWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INAlternativeLockScreenHomeCoinWidget: Widget {
    let kind: String = "AlternativeLockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(
                games: [.genshinImpact],
                recommendationsTag: "watch.info.RealmCurrency"
            )
        ) { entry in
            EmbeddedWidgets
                .AlternativeLockScreenHomeCoinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.homeCoin".i18nWidgets)
        .description("pzWidgetsKit.cfgName.homeCoin.2".i18nWidgets)
        .supportedFamilies([.accessoryCircular].backportsOnly)
    }
}

// MARK: - AlternativeLockScreenResinWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INAlternativeLockScreenResinWidget: Widget {
    let kind: String = "AlternativeLockScreenResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            EmbeddedWidgets
                .AlternativeLockScreenResinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail.2".i18nWidgets)
        .supportedFamilies([.accessoryCircular].backportsOnly)
    }
}

// MARK: - LockScreenAllInfoWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(
                recommendationsTag: "watch.info.dailyCommission"
            )
        ) { entry in
            EmbeddedWidgets
                .LockScreenAllInfoWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.generalInfo".i18nWidgets)
        .description("pzWidgetsKit.cfgName.generalInfo.detail".i18nWidgets)
        .supportedFamilies([.accessoryRectangular].backportsOnly)
    }
}

// MARK: - LockScreenDailyTaskWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenDailyTaskWidget: Widget {
    let kind: String = "LockScreenDailyTaskWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "watch.info.dailyCommission")
        ) { entry in
            EmbeddedWidgets
                .LockScreenDailyTaskWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.dailyTask".i18nWidgets)
        .description("pzWidgetsKit.cfgName.dailyCommission".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner].backportsOnly)
        #else
            .supportedFamilies([.accessoryCircular].backportsOnly)
        #endif
    }
}

// MARK: - LockScreenExpeditionWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenExpeditionWidget: Widget {
    let kind: String = "LockScreenExpeditionWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(
                games: [.genshinImpact, .starRail],
                recommendationsTag: "watch.info.expedition"
            )
        ) { entry in
            EmbeddedWidgets
                .LockScreenExpeditionWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.expedition".i18nWidgets)
        .description("pzWidgetsKit.cfgName.expedition".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner].backportsOnly)
        #else
            .supportedFamilies([.accessoryCircular].backportsOnly)
        #endif
    }
}

// MARK: - LockScreenHomeCoinWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenHomeCoinWidget: Widget {
    let kind: String = "LockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(
                games: [.genshinImpact],
                recommendationsTag: "watch.info.RealmCurrency"
            )
        ) { entry in
            EmbeddedWidgets
                .LockScreenHomeCoinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.homeCoin".i18nWidgets)
        .description("pzWidgetsKit.cfgName.homeCoin".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([
                .accessoryCircular,
                .accessoryCorner,
                .accessoryRectangular,
            ].backportsOnly)
        #else
            .supportedFamilies([.accessoryCircular, .accessoryRectangular].backportsOnly)
        #endif
    }
}

// MARK: - LockScreenLoopWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenLoopWidget: Widget {
    let kind: String = "LockScreenLoopWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenLoopWidgetProvider.Intent.self,
            provider: INLockScreenLoopWidgetProvider(
                recommendationsTag: "watch.info.autoRotation"
            )
        ) { entry in
            EmbeddedWidgets
                .LockScreenLoopWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.autoRotation".i18nWidgets)
        .description("pzWidgetsKit.cfgName.autoDisplay".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner].backportsOnly)
        #else
            .supportedFamilies([.accessoryCircular].backportsOnly)
        #endif
    }
}

// MARK: - LockScreenResinFullTimeWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenResinFullTimeWidget: Widget {
    let kind: String = "LockScreenResinFullTimeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.ofSb")
        ) { entry in
            EmbeddedWidgets
                .LockScreenResinFullTimeWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.show.title".i18nWidgets)
        .supportedFamilies([.accessoryCircular].backportsOnly)
        .contentMarginsDisabled()
    }
}

// MARK: - LockScreenResinTimerWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INLockScreenResinTimerWidget: Widget {
    let kind: String = "LockScreenResinTimerWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.countdown.ofSb")
        ) { entry in
            EmbeddedWidgets
                .LockScreenResinTimerWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.countdown.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.countdown.show.title".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCircular].backportsOnly)
        #else
            .supportedFamilies([.accessoryCircular].backportsOnly)
        #endif
    }
}

// MARK: - AlternativeWatchCornerResinWidget

@available(iOS 16.2, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
struct INAlternativeWatchCornerResinWidget: Widget {
    let kind: String = "AlternativeWatchCornerResinWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: INLockScreenWidgetProvider.Intent.self,
            provider: INLockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            EmbeddedWidgets
                .AlternativeWatchCornerResinWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCorner].backportsOnly)
        #endif
    }
}

#endif
