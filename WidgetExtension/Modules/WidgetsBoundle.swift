// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import WidgetKit

extension Array where Element == WidgetFamily {
    @MainActor var backportsOnly: Self {
        PZWidgets.useBackports ? self : []
    }
}

extension PZWidgets {
    @WidgetBundleBuilder @MainActor public static var widgets: some Widget {
        if #available(iOS 16.2, macCatalyst 16.2, *) {
            widgets4Desktop
            widgets4Embeddeds
        }
    }

    @available(iOS 16.2, macCatalyst 16.2, *)
    @WidgetBundleBuilder @MainActor public static var widgets4Desktop: some Widget {
        #if !os(watchOS)
        if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
            SingleProfileWidget()
            DualProfileWidget()
            OfficialFeedWidget()
        }
        INSingleProfileWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INDualProfileWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INOfficialFeedWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        MaterialWidget()
        #endif
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        StaminaTimerSharedActivityWidget()
        #endif
    }

    @available(iOS 16.2, macCatalyst 16.2, *)
    @WidgetBundleBuilder @MainActor public static var widgets4Embeddeds: some Widget {
        #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(watchOS)
        if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
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
        }
        INLockScreenResinWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenLoopWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenAllInfoWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenResinTimerWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenResinFullTimeWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenHomeCoinWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        #if !os(watchOS)
        // 洞天宝钱的环形进度条。这厮在 watchOS 系统下有莫名其妙的排版八哥，暂时排除。
        INAlternativeLockScreenHomeCoinWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        #endif
        INLockScreenDailyTaskWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INLockScreenExpeditionWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        INAlternativeLockScreenResinWidget() // 系统版本是 iOS 17+ 时，自动隐藏。
        #endif
    }

    @MainActor public static let useBackports: Bool = {
        guard !Pizza.isAppStoreReleaseAsLatteHelper else { return false }
        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *, watchOS 10.0, *) {
            return false
        }
        return true
    }()
}

// MARK: - WidgetExtensionBundle

@main
struct WidgetExtensionBundle: WidgetBundle {
    // MARK: Lifecycle

    init() {
        if #available(iOS 16.2, macCatalyst 16.2, *) {
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
