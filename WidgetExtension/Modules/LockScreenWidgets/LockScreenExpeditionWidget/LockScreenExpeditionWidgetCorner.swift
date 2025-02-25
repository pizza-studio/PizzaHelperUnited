// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - LockScreenExpeditionWidgetCorner

@available(macOS, unavailable)
struct LockScreenExpeditionWidgetCorner: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var text: String {
        switch result {
        case let .success(data):
            /// ZZZ Has no expedition intels available through API yet.
            switch data {
            case _ as Note4ZZZ: return "WRONG_GAME"
            default:
                let timeDescription: String = {
                    if data.allExpeditionsAccomplished {
                        return "pzWidgetsKit.status.done".i18nWidgets
                    } else if let maxFinishTime = data.expeditionTotalETA {
                        return formatter.string(from: maxFinishTime)
                    } else {
                        return ""
                    }
                }()

                let numerator = data.expeditionCompletionStatus.finished
                let denominator = data.expeditionCompletionStatus.all
                return "\(numerator) / \(denominator) \(timeDescription)"
            }
        case .failure:
            return "pzWidgetsKit.expedition".i18nWidgets
        }
    }

    var body: some View {
        Pizza.SupportedGame(dailyNoteResult: result).expeditionAssetSVG
            .resizable()
            .scaledToFit()
            .padding(4.5)
            .widgetLabel(text)
    }
}

private let formatter: DateFormatter = {
    let fmt = DateFormatter.CurrentLocale()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()
