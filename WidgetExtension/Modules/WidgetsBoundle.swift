// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import WidgetKit

extension PZWidgets {
    @WidgetBundleBuilder @MainActor @preconcurrency public static var widgets: some Widget {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        StaminaTimerSharedActivityWidget()
        #endif
        #if !os(watchOS)
        MainWidget()
        DualProfileWidget()
        MaterialWidget()
        OfficialFeedWidget()
        #endif
        #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(watchOS)
        widgets4MobilePlatforms
        #endif
    }

    #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(watchOS)
    @WidgetBundleBuilder @MainActor @preconcurrency public static var widgets4MobilePlatforms: some Widget {
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
    #endif
}

// MARK: - WidgetExtensionBundle

@main
struct WidgetExtensionBundle: WidgetBundle {
    // MARK: Lifecycle

    init() {
        PZWidgets.attemptToAutoInheritOldAccountsIntoProfiles()
    }

    // MARK: Internal

    var body: some Widget {
        PZWidgets.widgets
    }
}
