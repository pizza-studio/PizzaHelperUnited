// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import WidgetKit

extension PZWidgets {
    @WidgetBundleBuilder @MainActor public static var widgets: some Widget {
        if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
            widgets4Desktop
            widgets4Embeddeds
        }
    }

    @available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
    @WidgetBundleBuilder @MainActor public static var widgets4Desktop: some Widget {
        #if !os(watchOS)
        SingleProfileWidget()
        DualProfileWidget()
        OfficialFeedWidget()
        MaterialWidget()
        #endif
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        StaminaTimerSharedActivityWidget()
        #endif
    }

    @available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
    @WidgetBundleBuilder @MainActor public static var widgets4Embeddeds: some Widget {
        #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(watchOS)
        LockScreenResinWidget()
        LockScreenLoopWidget()
        LockScreenAllInfoWidget()
        LockScreenResinTimerWidget()
        LockScreenResinFullTimeWidget()
        LockScreenHomeCoinWidget()
        #if !os(watchOS)
        // 洞天宝钱的环形进度条。这厮在 watchOS 系统下有莫名其妙的排版八哥，暂时排除。
        AlternativeLockScreenHomeCoinWidget()
        #endif
        LockScreenDailyTaskWidget()
        LockScreenExpeditionWidget()
        AlternativeLockScreenResinWidget()
        #endif
    }
}

// MARK: - WidgetExtensionBundle

@main
struct WidgetExtensionBundle: WidgetBundle {
    // MARK: Lifecycle

    init() {
        if #available(iOS 17.0, macCatalyst 17.0, *) {
            PZWidgets.startupTask()
        }
    }

    // MARK: Internal

    var body: some Widget {
        PZWidgets.widgets
    }
}

// import Defaults
// import PZInGameEventKit
// import PZWidgetsKit
//
// #if DEBUG && !os(watchOS)
// #Preview(as: .systemLarge, widget: {
//    SingleProfileWidget()
// }, timeline: {
//    let date = Date()
//    let provider = SingleProfileWidgetProvider()
//    let game = Pizza.SupportedGame.genshinImpact
//  let config: WidgetViewConfig = {
//    var result = WidgetViewConfig.defaultConfig
//    result.useTinyGlassDisplayStyle = true
//    result.expeditionDisplayPolicy = .neverDisplay
//    return result
//  }()
//    let entry: ProfileWidgetEntry = {
//        let sampleData = Pizza.SupportedGame.genshinImpact.exampleDailyNoteData
//        let assetMap = sampleData.getExpeditionAssetMapImmediately()
//        return ProfileWidgetEntry(
//            date: Date(),
//            result: .success(game.exampleDailyNoteData),
//            viewConfig: config,
//            profile: .getDummyInstance(for: game),
//            pilotAssetMap: assetMap,
//            events: Defaults[.officialFeedCache].filter { $0.game == .genshinImpact }
//        )
//    }()
//    entry
// })
// #endif
