// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import WidgetKit

extension PZWidgets {
    @WidgetBundleBuilder @MainActor @preconcurrency public static var widgets: some Widget {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            ResinRecoveryActivityWidget()
        }
        #endif
        #if !os(watchOS)
        MainWidget()
        MaterialWidget()
        #endif
        #if os(iOS) && !targetEnvironment(macCatalyst)
        LockScreenResinWidget()
        LockScreenLoopWidget()
        LockScreenAllInfoWidget()
        LockScreenResinTimerWidget()
        LockScreenResinFullTimeWidget()
        LockScreenHomeCoinWidget()
        AlternativeLockScreenHomeCoinWidget()
        LockScreenDailyTaskWidget()
        LockScreenExpeditionWidget()
        AlternativeLockScreenResinWidget()
        #endif
    }
}
