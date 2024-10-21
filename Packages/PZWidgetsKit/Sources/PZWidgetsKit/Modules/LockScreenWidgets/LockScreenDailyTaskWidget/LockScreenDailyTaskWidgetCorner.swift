// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI

struct LockScreenDailyTaskWidgetCorner: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            Image("icon.dailyTask")
                .resizable()
                .scaledToFit()
                .padding(3.5)
                .widgetLabel {
                    Gauge(
                        value: Double(data.dailyTaskInformation.finishedTaskCount),
                        in: 0 ... Double(data.dailyTaskInformation.totalTaskCount)
                    ) {
                        Text("app.dailynote.card.dailyTask.label")
                    } currentValueLabel: {
                        Text(
                            "\(data.dailyTaskInformation.finishedTaskCount) / \(data.dailyTaskInformation.totalTaskCount)"
                        )
                    } minimumValueLabel: {
                        Text(
                            "  \(data.dailyTaskInformation.finishedTaskCount)/\(data.dailyTaskInformation.totalTaskCount)  "
                        )
                    } maximumValueLabel: {
                        Text("")
                    }
                }
        case .failure:
            Image("icon.dailyTask")
                .resizable()
                .scaledToFit()
                .padding(4.5)
                .widgetLabel("app.dailynote.card.dailyTask.label".localized)
        }
    }
}
