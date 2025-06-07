// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct AlternativeLockScreenHomeCoinWidgetCircular: View {
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
                    switch data {
                    case let data as any Note4GI:
                        let coinIntel = data.homeCoinInfo
                        Gauge(value: Double(coinIntel.currentHomeCoin) / Double(coinIntel.maxHomeCoin)) {
                            LinearGradient(
                                colors: [
                                    PZWidgetsSPM.Colors.IconColor.HomeCoin.darkBlue.suiColor,
                                    PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor,
                                    PZWidgetsSPM.Colors.IconColor.HomeCoin.lightBlue.suiColor,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(
                                Image(homeCoinMonochromeIconAssetName, bundle: .module)
                                    .resizable()
                                    .scaledToFit()
                            )
                        } currentValueLabel: {
                            let value = "\(coinIntel.currentHomeCoin)"
                            Text(verbatim: value)
                                .font(.title3)
                            #if !os(watchOS)
                                .fontWidth(value.count > 3 ? .condensed : .standard)
                            #endif
                                .minimumScaleFactor(0.1)
                        }
                        .gaugeStyle(
                            ProgressGaugeStyle(
                                circleColor: PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor
                            )
                        )
                    default:
                        Text(verbatim: "WRONG\nGAME")
                            .fontWidth(.compressed)
                            .multilineTextAlignment(.center)
                            .fixedSize()
                            .minimumScaleFactor(0.2)
                    }

                case .failure:
                    Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                        LinearGradient(
                            colors: [
                                PZWidgetsSPM.Colors.IconColor.HomeCoin.darkBlue.suiColor,
                                PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor,
                                PZWidgetsSPM.Colors.IconColor.HomeCoin.lightBlue.suiColor,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Image(homeCoinMonochromeIconAssetName, bundle: .module)
                                .resizable()
                                .scaledToFit()
                        )
                    } currentValueLabel: {
                        Image(systemSymbol: .ellipsis)
                    }
                    .gaugeStyle(
                        ProgressGaugeStyle(
                            circleColor: PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor
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
                            Image(homeCoinMonochromeIconAssetName, bundle: .module)
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
                            .multilineTextAlignment(.center)
                            .fixedSize()
                            .minimumScaleFactor(0.2)
                    }
                case .failure:
                    Gauge(value: Double(213), in: 0.0 ... Double(213)) {
                        Image(homeCoinMonochromeIconAssetName, bundle: .module)
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

        private var homeCoinMonochromeIconAssetName: String { "icon.homeCoin" }
    }
}
