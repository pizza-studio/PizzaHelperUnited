// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - WatchAccountDetailView

struct WatchAccountDetailView: View {
    // MARK: Lifecycle

    init(data: any DailyNoteProtocol, profile: PZProfileSendable) {
        self.data = data
        self.profile = profile
    }

    // MARK: Internal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Divider()
                WatchResinDetailView(dailyNote: data)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Text("\n\n" + profile.uidWithGame)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    if data.hasDailyTaskIntel {
                        let sitrep = data.dailyTaskCompletionStatus
                        let titleKey: LocalizedStringKey = switch data.game {
                        case .genshinImpact: "watch.dailyNote.card.dailyTask.label"
                        case .starRail: "watch.dailyNote.card.dailyTask.label"
                        case .zenlessZone: "watch.dailyNote.card.zzzVitality.label"
                        }
                        WatchAccountDetailItemView(
                            title: titleKey,
                            value: "\(sitrep.finished) / \(sitrep.all)",
                            icon: data.game.dailyTaskAssetIcon
                        )
                        Divider()
                    }

                    switch data {
                    case let data as any Note4GI: drawNote4GI(data)
                    case let data as any Note4HSR: drawNote4HSR(data)
                    case let data as Note4ZZZ: drawNote4ZZZ(data)
                    default: EmptyView()
                    }
                }
            }
        }
        .navigationTitle(profile.name)
    }

    // MARK: Private

    private var data: any DailyNoteProtocol
    private var profile: PZProfileSendable

    @ViewBuilder private var expeditionsList: some View {
        switch data {
        case _ as Note4ZZZ:
            EmptyView()
        default:
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                ForEach(
                    data.expeditionTasks,
                    id: \.iconURL
                ) { expedition in
                    WatchEachExpeditionView(
                        expedition: expedition,
                        useAsyncImage: true
                    )
                    .frame(maxHeight: 40)
                }
            }
        }
    }

    @ViewBuilder
    private func drawNote4GI(_ data: any Note4GI) -> some View {
        WatchAccountDetailItemView(
            title: "watch.dailyNote.card.homeCoin.label",
            value: "\(data.homeCoinInfo.currentHomeCoin)",
            icon: data.game.giRealmCurrencyAssetIcon
        )
        Divider()
        let expeditionIntel = data.expeditionCompletionStatus
        WatchAccountDetailItemView(
            title: "watch.dailyNote.card.expedition.label",
            value: "\(expeditionIntel.finished) / \(expeditionIntel.all)",
            icon: data.game.expeditionAssetIcon
        )
        Divider()
        if let data = data as? FullNote4GI {
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.transformer",
                value: intervalFormatter
                    .string(
                        from: TimeInterval
                            .sinceNow(to: data.transformerInfo.recoveryTime)
                    )!,
                icon: data.game.giTransformerAssetIcon
            )
            Divider()
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.giTrounceBlossom",
                value: data.weeklyBossesInfo.textDescription,
                icon: data.game.giTrounceBlossomAssetIcon
            )
            Divider()
        }
    }

    @ViewBuilder
    private func drawNote4HSR(_ data: any Note4HSR) -> some View {
        WatchAccountDetailItemView(
            title: "watch.dailyNote.card.simulatedUniverse.label",
            value: "\(data.simulatedUniverseInfo.currentScore) / \(data.simulatedUniverseInfo.maxScore)",
            icon: data.game.hsrSimulatedUniverseAssetIcon
        )
        Divider()
        let expeditionIntel = data.expeditionCompletionStatus
        WatchAccountDetailItemView(
            title: "watch.dailyNote.card.expedition.label",
            value: "\(expeditionIntel.finished) / \(expeditionIntel.all)",
            icon: data.game.expeditionAssetIcon
        )
        Divider()
        if let eowIntel = data.echoOfWarIntel {
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.hsrEchoOfWar.label",
                value: eowIntel.textDescription,
                icon: data.game.hsrEchoOfWarAssetIcon
            )
            Divider()
        }
    }

    @ViewBuilder
    private func drawNote4ZZZ(_ data: Note4ZZZ) -> some View {
        Group {
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.zzzVHSStoreInOperationState.label",
                value: String(data.vhsStoreState.localizedDescription),
                icon: data.game.zzzVHSStoreAssetIcon
            )
            Divider()
        }
        if let cardScratched = data.cardScratched {
            let stateDone: String.LocalizationValue = "watch.dailyNote.card.zzzScratchableCard.done"
            let stateNyet: String.LocalizationValue = "watch.dailyNote.card.zzzScratchableCard.notYet"
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.zzzScratchableCard.label",
                value: String(localized: cardScratched ? stateDone : stateNyet, bundle: .module),
                icon: data.game.zzzScratchCardAssetIcon
            )
            Divider()
        }
        if let bountyCommission = data.hollowZero.bountyCommission {
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.zzzHollowZeroBountyCommission.label",
                value: bountyCommission.textDescription,
                icon: data.game.zzzBountyAssetIcon
            )
            Divider()
        }
        if let investigationPoint = data.hollowZero.investigationPoint {
            WatchAccountDetailItemView(
                title: "watch.dailyNote.card.zzzHollowZeroInvestigationPoint.label",
                value: investigationPoint.textDescription,
                icon: data.game.zzzInvestigationPointsAssetIcon
            )
            Divider()
        }
    }
}

// MARK: - WatchEachExpeditionView

private struct WatchEachExpeditionView: View {
    let expedition: any ExpeditionTask
    var useAsyncImage: Bool = false
    var animationDelay: Double = 0

    var body: some View {
        HStack {
            AsyncImage(url: expedition.iconURL, content: { image in
                GeometryReader { g in
                    image.resizable()
                        .scaledToFit()
                        .scaleEffect(1.5)
                        .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
                }
            }, placeholder: {
                ProgressView()
            })
            .frame(width: 25, height: 25)
            VStack(alignment: .leading) {
                if let finishTime = expedition.timeOnFinish {
                    Text(intervalFormatter.string(from: TimeInterval.sinceNow(to: finishTime))!)
                        .font(.footnote)
                    percentageBar(TimeInterval.sinceNow(to: finishTime) / Double(20 * 60 * 60))
                } else {
                    Text(expedition.isFinished ? "watch.finished" : "watch.pending", bundle: .module)
                        .font(.footnote)
                    percentageBar(expedition.isFinished ? 0.5 : 1)
                }
            }
        }
        .foregroundColor(Color.white.opacity(0.95))
        .padding(.trailing)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule()
                    .opacity(0.3)
                    .frame(width: g.size.width, height: g.size.height)
                Capsule()
                    .frame(
                        width: g.size.width * percentage,
                        height: g.size.height
                    )
            }
            .aspectRatio(30 / 1, contentMode: .fit)
        }
        .frame(height: 7)
    }
}

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
