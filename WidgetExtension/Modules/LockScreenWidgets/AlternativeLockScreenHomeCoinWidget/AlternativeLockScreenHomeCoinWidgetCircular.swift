// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
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
                        Text(verbatim: "\(coinIntel.currentHomeCoin)")
                            .font(.system(.title3, design: .rounded))
                            .fixedSize()
                            .minimumScaleFactor(0.2)
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
                        Text(verbatim: "\(coinIntel.currentHomeCoin)")
                            .font(.system(.title3, design: .rounded))
                            .fixedSize()
                            .minimumScaleFactor(0.2)
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

    var body2: some View {
        VStack(spacing: 0) {
            Image("icon.homeCoin", bundle: .main)
                .resizable()
                .scaledToFit()
                .apply { imageView in
                    if widgetRenderingMode == .fullColor {
                        imageView
                            .foregroundColor(Color("iconColor.homeCoin.lightBlue", bundle: .main))
                    } else {
                        imageView
                    }
                }
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                default:
                    Text(verbatim: "WRONG GAME").fixedSize().fontWidth(.compressed)
                        .minimumScaleFactor(0.2)
                }
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
        .widgetAccentable(widgetRenderingMode == .accented)
        #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
        #else
            .padding(.vertical, 2)
        #endif
    }
}
