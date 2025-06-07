// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenLoopWidgetCircular

@available(macOS, unavailable)
struct LockScreenLoopWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    let result: Result<any DailyNoteProtocol, any Error>

    let resinStyle: PZWidgetsSPM.StaminaContentRevolverStyle

    var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
        case .resin:
            switch resinStyle {
            case .byDefault:
                AlternativeLockScreenResinWidgetCircular(entry: entry, result: result)
            case .timer:
                LockScreenResinTimerWidgetCircular(entry: entry, result: result)
            case .time:
                LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
            case .roundMeter:
                LockScreenResinWidgetCircular(entry: entry, result: result)
            }
        case .dailyTask:
            LockScreenDailyTaskWidgetCircular(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCircular(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCircular(entry: entry, result: result)
        }
    }
}
