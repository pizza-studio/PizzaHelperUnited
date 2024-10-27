// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct LockScreenLoopWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
        case .resin:
            LockScreenResinWidgetCorner(entry: entry, result: result)
        case .dailyTask:
            LockScreenDailyTaskWidgetCorner(result: result)
        case .expedition:
            LockScreenExpeditionWidgetCorner(result: result)
        case .homeCoin:
            LockScreenHomeCoinWidgetCorner(entry: entry, result: result)
        }
    }
}
