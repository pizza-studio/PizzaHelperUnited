// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenResinWidget: Widget {
    let kind: String = "LockScreenResinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
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
            ])
        #else
            .supportedFamilies([
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
            ])
        #endif
    }
}

// MARK: - AlternativeLockScreenHomeCoinWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct AlternativeLockScreenHomeCoinWidget: Widget {
    let kind: String = "AlternativeLockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(
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
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - AlternativeLockScreenResinWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct AlternativeLockScreenResinWidget: Widget {
    let kind: String = "AlternativeLockScreenResinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            EmbeddedWidgets
                .AlternativeLockScreenResinWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail.2".i18nWidgets)
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - LockScreenAllInfoWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(
                recommendationsTag: "watch.info.dailyCommission"
            )
        ) { entry in
            EmbeddedWidgets
                .LockScreenAllInfoWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.generalInfo".i18nWidgets)
        .description("pzWidgetsKit.cfgName.generalInfo.detail".i18nWidgets)
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - LockScreenDailyTaskWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenDailyTaskWidget: Widget {
    let kind: String = "LockScreenDailyTaskWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.dailyCommission")
        ) { entry in
            EmbeddedWidgets
                .LockScreenDailyTaskWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.dailyTask".i18nWidgets)
        .description("pzWidgetsKit.cfgName.dailyCommission".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenExpeditionWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenExpeditionWidget: Widget {
    let kind: String = "LockScreenExpeditionWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(
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
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenHomeCoinWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenHomeCoinWidget: Widget {
    let kind: String = "LockScreenHomeCoinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(
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
            ])
        #else
            .supportedFamilies([.accessoryCircular, .accessoryRectangular])
        #endif
    }
}

// MARK: - LockScreenLoopWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenLoopWidget: Widget {
    let kind: String = "LockScreenLoopWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileMisc.self,
            provider: LockScreenLoopWidgetProvider(
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
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenResinFullTimeWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenResinFullTimeWidget: Widget {
    let kind: String = "LockScreenResinFullTimeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.ofSb")
        ) { entry in
            EmbeddedWidgets
                .LockScreenResinFullTimeWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.show.title".i18nWidgets)
        .supportedFamilies([.accessoryCircular])
        .contentMarginsDisabled()
    }
}

// MARK: - LockScreenResinTimerWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct LockScreenResinTimerWidget: Widget {
    let kind: String = "LockScreenResinTimerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "pzWidgetsKit.stamina.refillTime.countdown.ofSb")
        ) { entry in
            EmbeddedWidgets
                .LockScreenResinTimerWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.stamina.refillTime.countdown.title".i18nWidgets)
        .description("pzWidgetsKit.stamina.refillTime.countdown.show.title".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCircular])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - AlternativeWatchCornerResinWidget

@available(iOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
struct AlternativeWatchCornerResinWidget: Widget {
    let kind: String = "AlternativeWatchCornerResinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PZEmbeddedIntent4ProfileOnly.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            EmbeddedWidgets
                .AlternativeWatchCornerResinWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.stamina".i18nWidgets)
        .description("pzWidgetsKit.cfgName.stamina.detail".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCorner])
        #endif
    }
}

#endif
