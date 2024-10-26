// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetCorner

struct LockScreenHomeCoinWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var text: String {
        switch result {
        case let .success(data):
            switch data {
            case let data as any Note4GI:
                let currentAmount = data.homeCoinInfo.currentHomeCoinDynamic
                let fullTime = TimeInterval.sinceNow(to: data.homeCoinInfo.fullTime)
                return "\(currentAmount), \(PZWidgets.intervalFormatter.string(from: fullTime)!)"
            default:
                return "WRONG_GAME"
            }
        case .failure:
            return "pzWidgetsKit.homeCoin".i18nWidgets
        }
    }

    @MainActor var body: some View {
        Image("icon.homeCoin", bundle: .module)
            .resizable()
            .scaledToFit()
            .padding(3)
            .widgetLabel(text)
    }
}
