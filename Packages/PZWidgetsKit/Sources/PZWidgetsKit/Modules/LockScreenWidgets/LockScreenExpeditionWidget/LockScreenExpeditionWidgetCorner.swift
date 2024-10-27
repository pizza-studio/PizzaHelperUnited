// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
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
            case let data as any Note4GI:
                let timeDescription: String = {
                    if data.expeditions.allCompleted {
                        return "pzWidgetsKit.status.done".i18nWidgets
                    } else {
                        if let expeditionInformation = data.expeditions as? GeneralNote4GI
                            .ExpeditionInfo4GI {
                            return formatter.string(from: expeditionInformation.expeditions.map(\.finishTime).max()!)
                        } else {
                            return ""
                        }
                    }
                }()

                let numerator = data.expeditionProgressCounts.ongoing
                let denominator = data.expeditionProgressCounts.all
                return "\(numerator) / \(denominator) \(timeDescription)"
            case let data as Note4HSR:
                let timeDescription: String = {
                    if data.assignmentInfo.allCompleted {
                        return "pzWidgetsKit.status.done".i18nWidgets
                    } else if let maxFinishTime = data.assignmentInfo.assignments.map(\.finishedTime).max() {
                        return formatter.string(from: maxFinishTime)
                    } else {
                        return ""
                    }
                }()

                let numerator = data.expeditionProgressCounts.ongoing
                let denominator = data.expeditionProgressCounts.all
                return "\(numerator) / \(denominator) \(timeDescription)"
            default:
                return ""
            }
        case .failure:
            return "pzWidgetsKit.expedition".i18nWidgets
        }
    }

    @MainActor var body: some View {
        Image("icon.expedition", bundle: .module)
            .resizable()
            .scaledToFit()
            .padding(3.5)
            .widgetLabel(text)
    }
}

private let formatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()
