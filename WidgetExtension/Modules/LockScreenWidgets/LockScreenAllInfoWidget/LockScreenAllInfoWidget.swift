// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenAllInfoWidget

@available(macOS, unavailable)
struct LockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(
                recommendationsTag: "watch.info.dailyCommission"
            )
        ) { entry in
            LockScreenAllInfoWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.generalInfo".i18nWidgets)
        .description("pzWidgetsKit.cfgName.generalInfo.detail".i18nWidgets)
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - LockScreenAllInfoWidgetView

@available(macOS, unavailable)
struct LockScreenAllInfoWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    let entry: LockScreenWidgetProvider.Entry

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }

    var staminaMonochromeIconAssetName: String {
        switch result {
        case let .success(data):
            return switch data.game {
            case .genshinImpact: "icon.resin"
            case .starRail: "icon.trailblazePower"
            case .zenlessZone: "icon.zzzBattery"
            }
        case .failure: return "icon.resin"
        }
    }

    var body: some View {
        Group {
            switch result {
            case let .success(data):
                Grid(
                    alignment: .leadingFirstTextBaseline,
                    horizontalSpacing: 3,
                    verticalSpacing: 2
                ) {
                    // ROW 1
                    GridRow(alignment: .lastTextBaseline) {
                        switch data {
                        case let data as any Note4GI:
                            Text("\(Image(staminaMonochromeIconAssetName, bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .main
                                ) : nil)
                            Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                        case let data as Note4HSR:
                            Text("\(Image(staminaMonochromeIconAssetName, bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .main
                                ) : nil)
                            Text(verbatim: "\(data.staminaInfo.currentStamina)")
                        case let data as Note4ZZZ:
                            Text("\(Image(staminaMonochromeIconAssetName, bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .main
                                ) : nil)
                            Text(verbatim: "\(data.energy.currentEnergyAmountDynamic)")
                        default: EmptyView()
                        }
                        Spacer()
                        switch data {
                        case let data as any Note4GI:
                            Text("\(Image("icon.expedition", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.expedition", bundle: .main) :
                                        nil
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(verbatim: "\(data.expeditions.ongoingExpeditionCount)")
                                Text(verbatim: " / \(data.expeditions.maxExpeditionsCount)")
                                    .font(.caption)
                            }
                        case let data as Note4HSR:
                            let expeditionDataPair = data.expeditionProgressCounts
                            let numerator = expeditionDataPair.ongoing
                            let denominator = expeditionDataPair.all
                            Text("\(Image("icon.expedition", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.expedition", bundle: .main) :
                                        nil
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(verbatim: "\(numerator)")
                                Text(verbatim: " / \(denominator)")
                                    .font(.caption)
                            }
                        case _ as Note4ZZZ: EmptyView() // ZZZ has no expedition API results yet.
                        default: EmptyView()
                        }
                        Spacer()
                    }
                    // ROW 2
                    GridRow(alignment: .lastTextBaseline) {
                        switch data {
                        case let data as any Note4GI:
                            Text("\(Image("icon.dailyTask", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.dailyTask", bundle: .main) :
                                        nil
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(verbatim: "\(data.dailyTaskInfo.finishedTaskCount)")
                                Text(verbatim: " / \(data.dailyTaskInfo.totalTaskCount)")
                                    .font(.caption)
                            }
                        case let data as Note4HSR:
                            if let data = data as? WidgetNote4HSR {
                                // Daily Training
                                Text("\(Image("icon.dailyTask", bundle: .main))")
                                    .widgetAccentable(widgetRenderingMode == .fullColor)
                                    .foregroundColor(
                                        widgetRenderingMode == .fullColor ? Color(
                                            "iconColor.dailyTask",
                                            bundle: .main
                                        ) : nil
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(verbatim: "\(data.dailyTrainingInfo.currentScore)")
                                    Text(verbatim: " / \(data.dailyTrainingInfo.maxScore)")
                                        .font(.caption)
                                }
                            } else {
                                EmptyView()
                            }
                        case let data as Note4ZZZ:
                            // Vitality
                            Text("\(Image("icon.dailyTask", bundle: .main))")
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(verbatim: "\(data.vitality.current)")
                                Text(verbatim: " / \(data.vitality.max)")
                                    .font(.caption)
                            }
                        default: EmptyView()
                        }
                        Spacer()
                        switch data {
                        case let data as any Note4GI:
                            Text("\(Image("icon.homeCoin", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.homeCoin", bundle: .main) :
                                        nil
                                )
                            Text(verbatim: "\(data.homeCoinInfo.currentHomeCoinDynamic)")
                        case let data as Note4HSR:
                            if let data = data as? WidgetNote4HSR {
                                // Simulated Universe
                                Text("\(Image("icon.simulatedUniverse", bundle: .main))")
                                    .widgetAccentable(widgetRenderingMode == .fullColor)
                                    .foregroundColor(
                                        widgetRenderingMode == .fullColor ? Color(
                                            "iconColor.homeCoin",
                                            bundle: .main
                                        ) : nil
                                    )
                                let currentScore = data.simulatedUniverseInfo.currentScore
                                let maxScore = data.simulatedUniverseInfo.maxScore
                                let ratio = (Double(currentScore) / Double(maxScore) * 100).rounded(.down)
                                Text(verbatim: "\(ratio)%")
                            } else {
                                EmptyView()
                            }
                        case _ as Note4ZZZ: EmptyView() // TODO: 可以额外扩充其他内容。
                        default: EmptyView()
                        }
                    }
                    // ROW 3
                    if let data = data as? GeneralNote4GI {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.transformer", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color(
                                        "iconColor.transformer",
                                        bundle: .main
                                    ) :
                                        nil
                                )
                            let day = Calendar.current.dateComponents(
                                [.day],
                                from: Date(),
                                to: data.transformerInfo.recoveryTime
                            ).day
                            if let day {
                                Text("pzWidgetsKit.unit.day:\(day)", bundle: .main)
                            } else if let mins = Calendar.current.dateComponents(
                                [.minute],
                                from: Date(),
                                to: data.transformerInfo.recoveryTime
                            ).minute {
                                Text("pzWidgetsKit.unit.minute:\(mins)", bundle: .main)
                            } else {
                                Text("\(Image(systemSymbol: .checkmarkCircle))")
                            }
                            Spacer()
                            Text("\(Image("icon.weeklyBosses", bundle: .main))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color(
                                        "iconColor.weeklyBosses",
                                        bundle: .main
                                    ) : nil
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(verbatim: "\(data.weeklyBossesInfo.remainResinDiscount)")
                                Text(verbatim: " / \(data.weeklyBossesInfo.totalResinDiscount)")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                    }
                }
            case .failure:
                Grid(
                    alignment: .leadingFirstTextBaseline,
                    horizontalSpacing: 3,
                    verticalSpacing: 2
                ) {
                    GridRow(alignment: .lastTextBaseline) {
                        Text("\(Image(staminaMonochromeIconAssetName, bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text(Image(systemSymbol: .ellipsis))
                        Spacer()
                        Text("\(Image("icon.expedition", bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        HStack(
                            alignment: .lastTextBaseline,
                            spacing: 0
                        ) {
                            Text(Image(systemSymbol: .ellipsis))
                        }
                        Spacer()
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        Text("\(Image("icon.homeCoin", bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text("\(Image(systemSymbol: .ellipsis))")
                        Spacer()
                        Text("\(Image("icon.dailyTask", bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        HStack(
                            alignment: .lastTextBaseline,
                            spacing: 0
                        ) {
                            Text(Image(systemSymbol: .ellipsis))
                        }
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        Text("\(Image("icon.transformer", bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text(Image(systemSymbol: .ellipsis))
                        Spacer()
                        Text("\(Image("icon.weeklyBosses", bundle: .main))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        HStack(
                            alignment: .lastTextBaseline,
                            spacing: 0
                        ) {
                            Text(Image(systemSymbol: .ellipsis))
                        }
                        Spacer()
                    }
                }
                .foregroundColor(.gray)
            }
        }
        .widgetURL(url)
    }
}
