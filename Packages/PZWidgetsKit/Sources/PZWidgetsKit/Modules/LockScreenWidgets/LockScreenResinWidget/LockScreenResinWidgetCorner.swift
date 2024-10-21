// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetCorner

struct LockScreenResinWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var text: String {
        switch result {
        case let .success(data):
            if data.resinInfo.calculatedCurrentResin(referTo: entry.date) >= data.resinInfo.maxResin {
                return "\(ResinInfo.defaultMaxResin), " + "已回满".localized
            } else {
                return "\(data.resinInfo.calculatedCurrentResin(referTo: entry.date)), \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.resinInfo.resinRecoveryTime))!), \(dateFormatter.string(from: data.resinInfo.resinRecoveryTime))"
            }
        case .failure:
            return "app.dailynote.card.resin.label".localized
        }
    }

    var body: some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(4)
            .widgetLabel(text)
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
