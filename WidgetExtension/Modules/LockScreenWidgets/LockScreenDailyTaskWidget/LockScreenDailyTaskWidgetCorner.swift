// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI

@available(macOS, unavailable)
struct LockScreenDailyTaskWidgetCorner: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            Image("icon.dailyTask", bundle: .main)
                .resizable()
                .scaledToFit()
                .padding(3.5)
                .widgetLabel {
                    switch data {
                    case let data as any Note4GI:
                        let valNow = data.dailyTaskInfo.finishedTaskCount
                        let valMax = data.dailyTaskInfo.totalTaskCount
                        Gauge(value: Double(valNow), in: 0 ... Double(valMax)) {
                            Text("pzWidgetsKit.dailyTask", bundle: .main)
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } currentValueLabel: {
                            Text(verbatim: "\(valNow) / \(valMax)")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } minimumValueLabel: {
                            Text(verbatim: "  \(valNow)/\(valMax)  ")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } maximumValueLabel: {
                            Text(verbatim: "")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        }
                    case let data as WidgetNote4HSR:
                        let valNow = data.dailyTrainingInfo.currentScore
                        let valMax = data.dailyTrainingInfo.maxScore
                        Gauge(value: Double(valNow), in: 0 ... Double(valMax)) {
                            Text("pzWidgetsKit.dailyTask", bundle: .main)
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } currentValueLabel: {
                            Text(verbatim: "\(valNow) / \(valMax)")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } minimumValueLabel: {
                            Text(verbatim: "  \(valNow)/\(valMax)  ")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        } maximumValueLabel: {
                            Text(verbatim: "")
                                .fixedSize()
                                .minimumScaleFactor(0.2)
                        }
                    default:
                        Image(systemSymbol: .ellipsis)
                    }
                }
        case .failure:
            Image("icon.dailyTask", bundle: .main)
                .resizable()
                .scaledToFit()
                .padding(4.5)
                .widgetLabel("pzWidgetsKit.dailyTask".i18nWidgets)
        }
    }
}
