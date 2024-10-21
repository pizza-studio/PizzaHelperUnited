// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetCorner

struct LockScreenHomeCoinWidgetCorner: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var text: String {
        switch result {
        case let .success(data):
            return "\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date)), \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.homeCoinInformation.fullTime))!)"
        case .failure:
            return "app.dailynote.card.homeCoin.label".localized
        }
    }

    var body: some View {
        Image("icon.homeCoin")
            .resizable()
            .scaledToFit()
            .padding(3)
            .widgetLabel(text)
    }
}

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
