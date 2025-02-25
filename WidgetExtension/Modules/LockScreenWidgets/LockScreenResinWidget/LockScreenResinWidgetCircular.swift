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
struct LockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                Gauge(value: Double(staminaIntel.finished) / Double(staminaIntel.all)) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
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
                        circleColor: Color("iconColor.resin.middle", bundle: .main)
                    )
                )
            case .failure:
                Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
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
                        circleColor: Color("iconColor.resin.middle", bundle: .main)
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
}
