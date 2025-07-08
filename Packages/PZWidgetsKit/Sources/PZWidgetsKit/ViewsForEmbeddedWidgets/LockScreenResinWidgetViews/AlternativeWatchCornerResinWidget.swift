// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - AlternativeWatchCornerResinWidgetView

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct AlternativeWatchCornerResinWidgetView: View {
        // MARK: Lifecycle

        public init(entry: ProfileWidgetEntry) {
            self.entry = entry
        }

        // MARK: Public

        public let entry: ProfileWidgetEntry

        public var body: some View {
            switch result {
            case let .success(data):
                resinView(data: data)
            case .failure:
                failureView()
            }
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var family: WidgetFamily

        private var result: Result<any DailyNoteProtocol, any Error> { entry.result }

        @ViewBuilder
        private func resinView(data: any DailyNoteProtocol) -> some View {
            switch data {
            case let data as any Note4GI:
                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .widgetLabel {
                        let resinInfo = data.resinInfo
                        Gauge(
                            value: Double(resinInfo.currentResinDynamic),
                            in: 0 ... Double(resinInfo.maxResin)
                        ) {
                            Text("pzWidgetsKit.stamina", bundle: .module)
                        } currentValueLabel: {
                            Text(verbatim: "\(resinInfo.currentResinDynamic)")
                        } minimumValueLabel: {
                            Text(verbatim: "\(resinInfo.currentResinDynamic)")
                        } maximumValueLabel: {
                            Text(verbatim: "")
                        }
                    }
            case let data as any Note4HSR:
                let staminaInfo = data.staminaInfo
                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .widgetLabel {
                        Gauge(
                            value: Double(staminaInfo.currentStamina),
                            in: 0 ... Double(staminaInfo.maxStamina)
                        ) {
                            Text("pzWidgetsKit.stamina", bundle: .module)
                        } currentValueLabel: {
                            Text(staminaInfo.currentStamina.description)
                        } minimumValueLabel: {
                            Text(staminaInfo.currentStamina.description)
                        } maximumValueLabel: {
                            Text(verbatim: "")
                        }
                    }
            case let data as Note4ZZZ:
                let energyInfo = data.energy
                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .widgetLabel {
                        Gauge(
                            value: Double(energyInfo.currentEnergyAmountDynamic),
                            in: 0 ... Double(energyInfo.progress.max)
                        ) {
                            Text("pzWidgetsKit.stamina", bundle: .module)
                        } currentValueLabel: {
                            Text(energyInfo.currentEnergyAmountDynamic.description)
                        } minimumValueLabel: {
                            Text(energyInfo.currentEnergyAmountDynamic.description)
                        } maximumValueLabel: {
                            Text(verbatim: "")
                        }
                    }
            default: EmptyView()
            }
        }

        @ViewBuilder
        private func failureView() -> some View {
            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                .resizable()
                .scaledToFit()
                .padding(6)
                .widgetLabel {
                    Gauge(value: 114, in: 114 ... 514) {
                        Text(verbatim: "……")
                    }
                }
        }
    }
}

#endif
