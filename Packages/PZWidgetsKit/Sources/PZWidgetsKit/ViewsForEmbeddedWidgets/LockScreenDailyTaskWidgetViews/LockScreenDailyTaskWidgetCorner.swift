// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(macOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
extension EmbeddedWidgets {
    public struct LockScreenDailyTaskWidgetCorner: View {
        // MARK: Lifecycle

        public init(result: Result<any DailyNoteProtocol, any Error>) {
            self.result = result
        }

        // MARK: Public

        public var body: some View {
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
                                Text("pzWidgetsKit.dailyTask", bundle: .module)
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
                    .widgetLabel(String(
                        localized: String.LocalizationValue(stringLiteral: "pzWidgetsKit.dailyTask"),
                        bundle: .module
                    ))
            }
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let result: Result<any DailyNoteProtocol, any Error>
    }
}
