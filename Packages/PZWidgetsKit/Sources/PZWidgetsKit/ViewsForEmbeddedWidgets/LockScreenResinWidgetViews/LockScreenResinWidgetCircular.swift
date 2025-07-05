// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
extension EmbeddedWidgets {
    public struct LockScreenResinWidgetCircular: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            switch widgetRenderingMode {
            case .fullColor:
                switch result {
                case let .success(data):
                    let staminaIntel = data.staminaIntel
                    Gauge(value: Double(staminaIntel.finished) / Double(staminaIntel.all)) {
                        LinearGradient(
                            colors: [
                                PZWidgetsSPM.Colors.IconColor.Resin.dark.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.light.suiColor,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                                .resizable()
                                .scaledToFit()
                        )
                    } currentValueLabel: {
                        let value = "\(staminaIntel.finished)"
                        Text(verbatim: value)
                            .font(.title3)
                            .fontWidth(value.count > 3 ? .condensed : .standard)
                            .minimumScaleFactor(0.1)
                    }
                    .gaugeStyle(
                        ProgressGaugeStyle(
                            circleColor: PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor
                        )
                    )
                case .failure:
                    Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                        LinearGradient(
                            colors: [
                                PZWidgetsSPM.Colors.IconColor.Resin.dark.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.light.suiColor,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                                .resizable()
                                .scaledToFit()
                        )
                    } currentValueLabel: {
                        Image(systemSymbol: .ellipsis)
                    }
                    .gaugeStyle(
                        ProgressGaugeStyle(
                            circleColor: PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor
                        )
                    )
                }
            default: // This includes the `.accented` case.
                switch result {
                case let .success(data):
                    let staminaIntel = data.staminaIntel
                    Gauge(value: Double(staminaIntel.finished) / Double(staminaIntel.all)) {
                        Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                            .resizable()
                            .scaledToFit()
                    } currentValueLabel: {
                        let value = "\(staminaIntel.finished)"
                        Text(verbatim: value)
                            .font(.title3)
                            .fontWidth(value.count > 3 ? .condensed : .standard)
                            .minimumScaleFactor(0.1)
                    }
                    .gaugeStyle(ProgressGaugeStyle())
                case .failure:
                    Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                        Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                            .resizable()
                            .scaledToFit()
                    } currentValueLabel: {
                        Image(systemSymbol: .ellipsis)
                    }
                    .gaugeStyle(ProgressGaugeStyle())
                }
            }
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let entry: any TimelineEntry
        private let result: Result<any DailyNoteProtocol, any Error>
    }
}
