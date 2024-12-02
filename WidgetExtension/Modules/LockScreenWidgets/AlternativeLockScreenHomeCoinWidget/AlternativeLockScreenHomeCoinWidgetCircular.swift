// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct AlternativeLockScreenHomeCoinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var homeCoinMonochromeIconAssetName: String { "icon.homeCoin" }

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    let coinIntel = data.homeCoinInfo
                    Gauge(value: Double(coinIntel.currentHomeCoin) / Double(coinIntel.maxHomeCoin)) {
                        LinearGradient(
                            colors: [
                                .init("iconColor.homeCoin.darkBlue"),
                                .init("iconColor.homeCoin.middle"),
                                .init("iconColor.homeCoin.lightBlue"),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Image(homeCoinMonochromeIconAssetName, bundle: .main)
                                .resizable()
                                .scaledToFit()
                        )
                    } currentValueLabel: {
                        let value = "\(coinIntel.currentHomeCoin)"
                        Text(verbatim: value)
                            .font(.title3)
                            .fontWidth(value.count > 3 ? .condensed : .standard)
                            .minimumScaleFactor(0.1)
                    }
                    .gaugeStyle(
                        ProgressGaugeStyle(
                            circleColor: Color("iconColor.homeCoin.middle", bundle: .main)
                        )
                    )
                default:
                    Text(verbatim: "WRONG\nGAME")
                        .fontWidth(.compressed)
                        .fixedSize()
                        .minimumScaleFactor(0.2)
                }

            case .failure:
                Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.homeCoin.darkBlue"),
                            .init("iconColor.homeCoin.middle"),
                            .init("iconColor.homeCoin.lightBlue"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Image(homeCoinMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                    )
                } currentValueLabel: {
                    Image(systemSymbol: .ellipsis)
                }
                .gaugeStyle(
                    ProgressGaugeStyle(
                        circleColor: Color("iconColor.homeCoin.middle", bundle: .main)
                    )
                )
            }
        default: // This includes the `.accented` case.
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    let coinIntel = data.homeCoinInfo
                    Gauge(value: Double(coinIntel.currentHomeCoin) / Double(coinIntel.maxHomeCoin)) {
                        Image(homeCoinMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                    } currentValueLabel: {
                        let value = "\(coinIntel.currentHomeCoin)"
                        Text(verbatim: value)
                            .font(.title3)
                            .fontWidth(value.count > 3 ? .condensed : .standard)
                            .minimumScaleFactor(0.1)
                    }
                    .gaugeStyle(ProgressGaugeStyle())
                default:
                    Text(verbatim: "WRONG\nGAME")
                        .fontWidth(.compressed)
                        .fixedSize()
                        .minimumScaleFactor(0.2)
                }
            case .failure:
                Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                    Image(homeCoinMonochromeIconAssetName, bundle: .main)
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
