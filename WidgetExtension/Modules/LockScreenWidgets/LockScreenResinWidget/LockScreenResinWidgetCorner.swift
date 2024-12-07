// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetCorner

@available(macOS, unavailable)
struct LockScreenResinWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var text: String {
        switch result {
        case let .success(data):
            let staminaIntel = data.staminaIntel
            let timeOnFinish = data.staminaFullTimeOnFinish
            if staminaIntel.isAccomplished {
                return "\(data.maxPrimaryStamina), " + "已回满".i18nWidgets
            } else {
                return "\(staminaIntel.finished), \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: timeOnFinish))!), \(PZWidgets.dateFormatter.string(from: timeOnFinish))"
            }
        case .failure:
            return "pzWidgetsKit.stamina.label".i18nWidgets
        }
    }

    var body: some View {
        Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
            .resizable()
            .scaledToFit()
            .padding(4)
            .widgetLabel(text)
    }
}
