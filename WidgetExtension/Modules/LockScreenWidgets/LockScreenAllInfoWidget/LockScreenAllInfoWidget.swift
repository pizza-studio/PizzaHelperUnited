// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
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

    var isFullColor: Bool { widgetRenderingMode == .fullColor }

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
                        HStack(spacing: 4) {
                            let staminaIntel = data.staminaIntel
                            Text("\(Image(staminaMonochromeIconAssetName, bundle: .main))")
                                .widgetAccentable(isFullColor)
                                .foregroundColor(isFullColor ? Color(
                                    "iconColor.resin",
                                    bundle: .main
                                ) : nil)
                            Text(verbatim: "\(staminaIntel.finished)")
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack(spacing: 4) {
                            switch data {
                            case let data as Note4ZZZ:
                                // ZZZ has no expedition API results yet, displaying 刮刮乐 instead.
                                if let cardScratched = data.cardScratched {
                                    Text("\(Image("icon.zzzScratch", bundle: .main))")
                                        .widgetAccentable(isFullColor)
                                        .foregroundColor(isFullColor ? Color(
                                            "iconColor.expedition",
                                            bundle: .main
                                        ) : nil)
                                    let stateName = cardScratched ? "icon.zzzScratch.done" : "icon.zzzScratch.available"
                                    Text("\(Image(stateName, bundle: .main))")
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    EmptyView()
                                }
                            default:
                                let icon = switch data.game {
                                case .genshinImpact: "icon.expedition.gi"
                                case .starRail: "icon.expedition.hsr"
                                case .zenlessZone: "icon.114514"
                                }
                                Text("\(Image(icon, bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color("iconColor.expedition", bundle: .main) :
                                            nil
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    let progression = data.expeditionCompletionStatus
                                    Text(verbatim: "\(progression.finished)")
                                        .minimumScaleFactor(0.2)
                                    Text(verbatim: " / \(progression.all)")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .minimumScaleFactor(0.2)
                            }
                        }
                    }
                    // ROW 2
                    GridRow(alignment: .lastTextBaseline) {
                        HStack(spacing: 4) {
                            if data.hasDailyTaskIntel {
                                let sitrep = data.dailyTaskCompletionStatus
                                let icon = switch data.game {
                                case .genshinImpact: "icon.dailyTask.gi"
                                case .starRail: "icon.dailyTask.hsr"
                                case .zenlessZone: "icon.dailyTask.zzz"
                                }
                                Text("\(Image(icon, bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color("iconColor.dailyTask", bundle: .main) :
                                            nil
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(verbatim: "\(sitrep.finished)")
                                        .minimumScaleFactor(0.2)
                                    Text(verbatim: " / \(sitrep.all)")
                                        .font(.caption)
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                EmptyView()
                            }
                        }

                        HStack(spacing: 4) {
                            switch data {
                            case let data as any Note4GI:
                                Text("\(Image("icon.homeCoin", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color("iconColor.homeCoin", bundle: .main) :
                                            nil
                                    )
                                Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
                                    .minimumScaleFactor(0.2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            case let data as Note4HSR:
                                // Simulated Universe
                                Text("\(Image("icon.simulatedUniverse", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color(
                                            "iconColor.homeCoin",
                                            bundle: .main
                                        ) : nil
                                    )
                                let currentScore = data.simulatedUniverseInfo.currentScore
                                let maxScore = data.simulatedUniverseInfo.maxScore
                                let ratio = (Double(currentScore) / Double(maxScore) * 100).rounded(.down)
                                Text(verbatim: "\(ratio)%")
                                    .minimumScaleFactor(0.2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            case let data as Note4ZZZ:
                                // VHS Store.
                                let isVHSInOperation = data.vhsStoreState.isInOperation
                                Text("\(Image("icon.zzzVHSStore", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(isFullColor ? Color(
                                        "iconColor.homeCoin",
                                        bundle: .main
                                    ) : nil)
                                let stateName = isVHSInOperation ? "icon.zzzVHSStore.inOperation" :
                                    "icon.zzzVHSStore.sleeping"
                                Text("\(Image(stateName, bundle: .main))")
                                    .minimumScaleFactor(0.2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            default: EmptyView()
                            }
                        }
                    }
                    // ROW 3
                    switch data {
                    case let data as Note4HSR where data.echoOfWarIntel != nil:
                        if let eowIntel = data.echoOfWarIntel {
                            GridRow(alignment: .lastTextBaseline) {
                                HStack(spacing: 4) {
                                    Text("\(Image("icon.echoOfWar", bundle: .main))")
                                        .widgetAccentable(isFullColor)
                                        .foregroundColor(
                                            isFullColor ? Color(
                                                "iconColor.weeklyBosses",
                                                bundle: .main
                                            ) : nil
                                        )
                                    HStack(
                                        alignment: .lastTextBaseline,
                                        spacing: 0
                                    ) {
                                        if eowIntel.allRewardsClaimed {
                                            Text(verbatim: "✔︎")
                                                .minimumScaleFactor(0.2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        } else { Text(verbatim: "\(eowIntel.weeklyEOWRewardsLeft)")
                                            Text(verbatim: " / \(eowIntel.weeklyEOWMaxRewards)")
                                                .font(.caption)
                                                .minimumScaleFactor(0.2)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                HStack(spacing: 4) {
                                    Spacer() // Icon Space
                                    Spacer() // Text Space
                                }
                            }
                        }
                    case let data as GeneralNote4GI:
                        GridRow(alignment: .lastTextBaseline) {
                            HStack(spacing: 4) {
                                Text("\(Image("icon.transformer", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color(
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
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else if let mins = Calendar.current.dateComponents(
                                    [.minute],
                                    from: Date(),
                                    to: data.transformerInfo.recoveryTime
                                ).minute {
                                    Text("pzWidgetsKit.unit.minute:\(mins)", bundle: .main)
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(verbatim: "✔︎")
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            HStack(spacing: 4) {
                                Text("\(Image("icon.trounceBlossom", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(
                                        isFullColor ? Color(
                                            "iconColor.weeklyBosses",
                                            bundle: .main
                                        ) : nil
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    let trounceBlossomIntel = data.weeklyBossesInfo
                                    if trounceBlossomIntel.allDiscountsAreUsedUp {
                                        Text(verbatim: "✔︎")
                                            .minimumScaleFactor(0.2)
                                    } else {
                                        Text(verbatim: "\(trounceBlossomIntel.remainResinDiscount)")
                                            .minimumScaleFactor(0.2)
                                        Text(verbatim: " / \(trounceBlossomIntel.totalResinDiscount)")
                                            .font(.caption)
                                            .minimumScaleFactor(0.2)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    case let data as Note4ZZZ:
                        GridRow(alignment: .lastTextBaseline) {
                            // 零号空洞每周悬赏委托
                            HStack(spacing: 4) {
                                Text("\(Image("icon.zzzBounty", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(isFullColor ? Color(
                                        "iconColor.transformer",
                                        bundle: .main
                                    ) : nil)
                                if let bountyIntel = data.hollowZero.bountyCommission {
                                    Text(verbatim: "\(bountyIntel.num)")
                                        .minimumScaleFactor(0.2)
                                    Text(verbatim: " / \(bountyIntel.total)")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("\(Image("icon.info.unavailable", bundle: .main))")
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            // 调查点数
                            HStack(spacing: 4) {
                                Text("\(Image("icon.zzzInvestigation", bundle: .main))")
                                    .widgetAccentable(isFullColor)
                                    .foregroundColor(isFullColor ? Color(
                                        "iconColor.weeklyBosses",
                                        bundle: .main
                                    ) : nil)
                                if let bountyIntel = data.hollowZero.investigationPoint {
                                    Text(verbatim: "\(bountyIntel.num)")
                                        .minimumScaleFactor(0.2)
                                    Text(verbatim: " / \(bountyIntel.total)")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text("\(Image("icon.info.unavailable", bundle: .main))")
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .fontWidth(.condensed)
            case .failure:
                Image(systemSymbol: .ellipsis)
                    .foregroundColor(.gray)
            }
        }
        .widgetURL(url)
    }
}
