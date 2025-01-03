// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(macOS, unavailable)
struct LockScreenDailyTaskWidgetCorner: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            Pizza.SupportedGame(dailyNoteResult: result).dailyTaskAssetSVG
                .resizable()
                .scaledToFit()
                .padding(3.5)
                .widgetLabel {
                    if data.hasDailyTaskIntel {
                        let sitrep = data.dailyTaskCompletionStatus
                        let valNow = sitrep.finished
                        let valMax = sitrep.all
                        Gauge(value: Double(valNow), in: 0 ... Double(valMax)) {
                            Text("pzWidgetsKit.dailyTask", bundle: .main)
                        } currentValueLabel: {
                            Text(verbatim: "\(valNow) / \(valMax)")
                        } minimumValueLabel: {
                            Text(verbatim: "  \(valNow)/\(valMax)  ")
                        } maximumValueLabel: {
                            Text(verbatim: "")
                        }
                    } else {
                        Image(systemSymbol: .ellipsis)
                    }
                }
        case .failure:
            Pizza.SupportedGame(dailyNoteResult: result).dailyTaskAssetSVG
                .resizable()
                .scaledToFit()
                .padding(4)
                .widgetLabel("pzWidgetsKit.dailyTask".i18nWidgets)
        }
    }
}
