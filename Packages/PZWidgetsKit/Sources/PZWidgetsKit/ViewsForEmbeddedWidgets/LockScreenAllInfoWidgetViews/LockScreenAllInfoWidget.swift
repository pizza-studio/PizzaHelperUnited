// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenAllInfoWidgetView

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: - LockScreenAllInfoWidgetView

    public struct LockScreenAllInfoWidgetView: View {
        // MARK: Lifecycle

        public init(entry: ProfileWidgetEntry) {
            self.entry = entry
        }

        // MARK: Public

        public let entry: ProfileWidgetEntry

        public var body: some View {
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
                            cellR1C1(data)
                            cellR1C2(data)
                        }
                        // ROW 2
                        GridRow(alignment: .lastTextBaseline) {
                            cellR2C1(data)
                            cellR2C2(data)
                        }
                        // ROW 3
                        row3(data)
                    }
                    .frame(maxWidth: .infinity)
                case .failure:
                    Image(systemSymbol: .ellipsis)
                        .foregroundColor(.gray)
                }
            }
            .widgetURL(url)
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var family: WidgetFamily
        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private var result: Result<any DailyNoteProtocol, any Error> { entry.result }

        private var url: URL? {
            let errorURL: URL = {
                var components = URLComponents()
                components.scheme = "ophelperwidget"
                components.host = "accountSetting"
                components.queryItems = [
                    .init(
                        name: "accountUUIDString",
                        value: entry.profile?.uuid.uuidString
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

        private var isFullColor: Bool { widgetRenderingMode == .fullColor }

        @ViewBuilder
        private func cellR1C1(_ data: any DailyNoteProtocol) -> some View {
            Group {
                let staminaIntel = data.staminaIntel
                Label {
                    Text(verbatim: "\(staminaIntel.finished)")
                        .minimumScaleFactor(0.2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    data.game.primaryStaminaSVGAsInlineText
                        .minimumScaleFactor(0.2)
                        .frame(maxWidth: 18, maxHeight: 18)
                        .widgetAccentable(isFullColor)
                        .foregroundColor(
                            isFullColor ? PZWidgetsSPM.Colors.IconColor.Resin.accented.suiColor : nil
                        )
                }
            }
        }

        @ViewBuilder
        private func cellR1C2(_ data: any DailyNoteProtocol) -> some View {
            Group {
                switch data {
                case let data as Note4ZZZ:
                    // ZZZ has no expedition API results yet, displaying 刮刮乐 instead.
                    if let cardScratched = data.cardScratched {
                        Label {
                            data.game.zzzScratchCardStateAssetSVGAsInlineText(isDone: cardScratched)
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            data.game.zzzScratchCardSVGAsInlineText
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: 18, maxHeight: 18)
                                .widgetAccentable(isFullColor)
                                .foregroundColor(isFullColor ? PZWidgetsSPM.Colors.IconColor.expedition.suiColor : nil)
                        }
                    } else {
                        EmptyView()
                    }
                default:
                    Label {
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
                    } icon: {
                        data.game.expeditionSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(isFullColor ? PZWidgetsSPM.Colors.IconColor.expedition.suiColor : nil)
                    }
                }
            }
        }

        @ViewBuilder
        private func cellR2C1(_ data: any DailyNoteProtocol) -> some View {
            Group {
                if data.hasDailyTaskIntel {
                    Label {
                        let sitrep = data.dailyTaskCompletionStatus
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
                    } icon: {
                        data.game.dailyTaskSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.dailyTask.suiColor : nil
                            )
                    }
                } else {
                    EmptyView()
                }
            }
        }

        @ViewBuilder
        private func cellR2C2(_ data: any DailyNoteProtocol) -> some View {
            Group {
                switch data {
                case let data as any Note4GI:
                    Label {
                        Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        data.game.giRealmCurrencySVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor : nil
                            )
                    }
                case let data as any Note4HSR:
                    // Simulated Universe
                    Label {
                        let currentScore = data.simulatedUniverseInfo.currentScore
                        let maxScore = data.simulatedUniverseInfo.maxScore
                        let ratio = maxScore > 0 ? (Double(currentScore) / Double(maxScore) * 100).rounded(.down) : 0.0
                        Text(verbatim: "\(ratio)%")
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        data.game.hsrSimulatedUniverseSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor : nil
                            )
                    }
                case let data as Note4ZZZ:
                    // VHS Store.
                    Label {
                        let isVHSInOperation = data.vhsStoreState.isInOperation
                        data.game.zzzVHSStoreStateAssetSVGAsInlineText(isSleeping: !isVHSInOperation)
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        data.game.zzzVHSStoreSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.HomeCoin.accented.suiColor : nil
                            )
                    }
                default: EmptyView()
                }
            }
        }

        @ViewBuilder
        private func row3(_ data: any DailyNoteProtocol) -> some View {
            switch data {
            case let data as any Note4HSR where data.echoOfWarIntel != nil:
                if let eowIntel = data.echoOfWarIntel {
                    GridRow(alignment: .lastTextBaseline) {
                        Label {
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                if eowIntel.allRewardsClaimed {
                                    Text(verbatim: "✔︎")
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(verbatim: "\(eowIntel.weeklyEOWRewardsLeft)")
                                    Text(verbatim: " / \(eowIntel.weeklyEOWMaxRewards)")
                                        .font(.caption)
                                        .minimumScaleFactor(0.2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        } icon: {
                            data.game.hsrEchoOfWarSVGAsInlineText
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: 18, maxHeight: 18)
                                .widgetAccentable(isFullColor)
                                .foregroundColor(
                                    isFullColor ? PZWidgetsSPM.Colors.IconColor.weeklyBosses.suiColor : nil
                                )
                        }
                        Label {
                            Spacer()
                        } icon: {
                            Spacer() // Icon Space
                        }
                    }
                }
            case let data as FullNote4GI:
                GridRow(alignment: .lastTextBaseline) {
                    Label {
                        let day = Calendar.gregorian.dateComponents(
                            [.day],
                            from: Date(),
                            to: data.transformerInfo.recoveryTime
                        ).day
                        if let day {
                            Text("pzWidgetsKit.unit.day:\(day)", bundle: .module)
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let mins = Calendar.gregorian.dateComponents(
                            [.minute],
                            from: Date(),
                            to: data.transformerInfo.recoveryTime
                        ).minute {
                            Text("pzWidgetsKit.unit.minute:\(mins)", bundle: .module)
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(verbatim: "✔︎")
                                .minimumScaleFactor(0.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } icon: {
                        data.game.giTransformerSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.transformer.suiColor : nil
                            )
                    }
                    Label {
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
                    } icon: {
                        data.game.giTrounceBlossomSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.weeklyBosses.suiColor : nil
                            )
                    }
                }
            case let data as Note4ZZZ:
                GridRow(alignment: .lastTextBaseline) {
                    // 零号空洞每周悬赏委托
                    Label {
                        HStack {
                            if let bountyIntel = data.hollowZero.bountyCommission {
                                Text(verbatim: "\(bountyIntel.num)")
                                    .minimumScaleFactor(0.2)
                                Text(verbatim: " / \(bountyIntel.total)")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Image(systemSymbol: .slashCircle)
                            }
                        }
                    } icon: {
                        data.game.zzzBountySVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.transformer.suiColor : nil
                            )
                    }
                    // 调查点数
                    Label {
                        HStack {
                            if let bountyIntel = data.hollowZero.investigationPoint {
                                Text(verbatim: "\(bountyIntel.num)")
                                    .minimumScaleFactor(0.2)
                                Text(verbatim: " / \(bountyIntel.total)")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Image(systemSymbol: .slashCircle)
                            }
                        }
                    } icon: {
                        data.game.zzzInvestigationPointsSVGAsInlineText
                            .minimumScaleFactor(0.2)
                            .frame(maxWidth: 18, maxHeight: 18)
                            .widgetAccentable(isFullColor)
                            .foregroundColor(
                                isFullColor ? PZWidgetsSPM.Colors.IconColor.weeklyBosses.suiColor : nil
                            )
                    }
                }
            default: EmptyView()
            }
        }
    }
}

#endif
