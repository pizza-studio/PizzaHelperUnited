// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
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

    @MainActor var body: some View {
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
                            Text(verbatim: "\(Image(staminaMonochromeIconAssetName, bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .module
                                ) : nil)
                            Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                        case let data as Note4HSR:
                            Text(verbatim: "\(Image(staminaMonochromeIconAssetName, bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .module
                                ) : nil)
                            Text(verbatim: "\(data.staminaInfo.currentStamina)")
                        case let data as Note4ZZZ:
                            Text(verbatim: "\(Image(staminaMonochromeIconAssetName, bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(widgetRenderingMode == .fullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .module
                                ) : nil)
                            Text(verbatim: "\(data.energy.currentEnergyAmountDynamic)")
                        default: EmptyView()
                        }
                        Spacer()
                        switch data {
                        case let data as any Note4GI:
                            Text(verbatim: "\(Image("icon.expedition", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.expedition", bundle: .module) :
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
                            Text(verbatim: "\(Image("icon.expedition", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.expedition", bundle: .module) :
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
                            Text(verbatim: "\(Image("icon.homeCoin", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.homeCoin", bundle: .module) :
                                        nil
                                )
                            Text(verbatim: "\(data.homeCoinInfo.currentHomeCoinDynamic)")
                        case let data as Note4HSR:
                            if let data = data as? WidgetNote4HSR {
                                // Simulated Universe
                                Text(verbatim: "\(Image(systemSymbol: .globeBadgeChevronBackward))")
                                    .widgetAccentable(widgetRenderingMode == .fullColor)
                                    .foregroundColor(
                                        widgetRenderingMode == .fullColor ? Color(
                                            "iconColor.homeCoin",
                                            bundle: .module
                                        ) : nil
                                    )
                                let currentScore = data.simulatedUniverseInfo.currentScore
                                let maxScore = data.simulatedUniverseInfo.maxScore
                                Text(verbatim: "\(currentScore) / \(maxScore)")
                            } else {
                                EmptyView()
                            }
                        case _ as Note4ZZZ: EmptyView() // TODO: 可以额外扩充其他内容。
                        default: EmptyView()
                        }
                        Spacer()
                        switch data {
                        case let data as any Note4GI:
                            Text(verbatim: "\(Image("icon.dailyTask", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color("iconColor.dailyTask", bundle: .module) :
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
                                Text(verbatim: "\(Image("icon.dailyTask", bundle: .module))")
                                    .widgetAccentable(widgetRenderingMode == .fullColor)
                                    .foregroundColor(
                                        widgetRenderingMode == .fullColor ? Color(
                                            "iconColor.dailyTask",
                                            bundle: .module
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
                            Text(verbatim: "VITALITY")
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
                    }
                    // ROW 3
                    if let data = data as? GeneralNote4GI {
                        GridRow(alignment: .lastTextBaseline) {
                            Text(verbatim: "\(Image("icon.transformer", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color(
                                        "iconColor.transformer",
                                        bundle: .module
                                    ) :
                                        nil
                                )
                            let day = Calendar.current.dateComponents(
                                [.day],
                                from: Date(),
                                to: data.transformerInfo.recoveryTime
                            ).day!
                            Text("pzWidgetsKit.unit.day:\(day)", bundle: .module)
                            Spacer()
                            Text(verbatim: "\(Image("icon.weeklyBosses", bundle: .module))")
                                .widgetAccentable(widgetRenderingMode == .fullColor)
                                .foregroundColor(
                                    widgetRenderingMode == .fullColor ? Color(
                                        "iconColor.weeklyBosses",
                                        bundle: .module
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
                        Text(verbatim: "\(Image(staminaMonochromeIconAssetName, bundle: .module))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text(Image(systemSymbol: .ellipsis))
                        Spacer()
                        Text(verbatim: "\(Image("icon.expedition", bundle: .module))")
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
                        Text(verbatim: "\(Image("icon.homeCoin", bundle: .module))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text(verbatim: "\(Image(systemSymbol: .ellipsis))")
                        Spacer()
                        Text(verbatim: "\(Image("icon.dailyTask", bundle: .module))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        HStack(
                            alignment: .lastTextBaseline,
                            spacing: 0
                        ) {
                            Text(Image(systemSymbol: .ellipsis))
                        }
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        Text(verbatim: "\(Image("icon.transformer", bundle: .module))")
                            .widgetAccentable(widgetRenderingMode == .fullColor)
                        Text(Image(systemSymbol: .ellipsis))
                        Spacer()
                        Text(verbatim: "\(Image("icon.weeklyBosses", bundle: .module))")
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
