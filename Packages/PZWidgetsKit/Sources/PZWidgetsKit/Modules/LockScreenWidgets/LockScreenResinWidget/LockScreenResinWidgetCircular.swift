// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct LockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                Gauge(
                    value: Double(data.resinInfo.calculatedCurrentResin(referTo: entry.date)) /
                        Double(data.resinInfo.maxResin)
                ) {
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
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                    )
                } currentValueLabel: {
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.title3, design: .rounded))
                        .minimumScaleFactor(0.1)
                }
                .gaugeStyle(
                    ProgressGaugeStyle(
                        circleColor: Color("iconColor.resin.middle")
                    )
                )
            case .failure:
                Gauge(value: Double(ResinInfo.defaultMaxResin), in: 0.0 ... Double(ResinInfo.defaultMaxResin)) {
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
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                    )
                } currentValueLabel: {
                    Image(systemSymbol: .ellipsis)
                }
                .gaugeStyle(
                    ProgressGaugeStyle(
                        circleColor: Color("iconColor.resin.middle")
                    )
                )
            }
        case .accented:
            switch result {
            case let .success(data):
                Gauge(
                    value: Double(data.resinInfo.calculatedCurrentResin(referTo: entry.date)) /
                        Double(data.resinInfo.maxResin)
                ) {
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                } currentValueLabel: {
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.title3, design: .rounded))
                        .minimumScaleFactor(0.1)
                }
                .gaugeStyle(ProgressGaugeStyle())
            case .failure:
                Gauge(value: Double(ResinInfo.defaultMaxResin), in: 0.0 ... Double(ResinInfo.defaultMaxResin)) {
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                } currentValueLabel: {
                    Image(systemSymbol: .ellipsis)
                }
                .gaugeStyle(ProgressGaugeStyle())
            }
        default:
            switch result {
            case let .success(data):
                Gauge(
                    value: Double(data.resinInfo.calculatedCurrentResin(referTo: entry.date)) /
                        Double(data.resinInfo.maxResin)
                ) {
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                } currentValueLabel: {
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.title3, design: .rounded))
                        .minimumScaleFactor(0.1)
                }
                .gaugeStyle(ProgressGaugeStyle())
            case .failure:
                Gauge(value: Double(ResinInfo.defaultMaxResin), in: 0.0 ... Double(ResinInfo.defaultMaxResin)) {
                    Image("icon.resin")
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
