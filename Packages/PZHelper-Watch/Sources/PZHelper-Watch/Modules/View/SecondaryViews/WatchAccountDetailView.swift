// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - WatchAccountDetailView

struct WatchAccountDetailView: View {
    var data: any DailyNoteProtocol
    let accountName: String?
    var uid: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Divider()
                    WatchResinDetailView(dailyNote: data)
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        if data.hasDailyTaskIntel {
                            let sitrep = data.dailyTaskCompletionStatus
                            let titleKey: LocalizedStringKey = switch data.game {
                            case .genshinImpact: "watch.dailyNote.card.dailyTask.label"
                            case .starRail: "watch.dailyNote.card.dailyTask.label"
                            case .zenlessZone: "watch.dailyNote.card.vitality.label"
                            }
                            let dailyTaskIcon = switch data.game {
                            case .genshinImpact: "gi_note_dailyTask"
                            case .starRail: "hsr_note_dailyTask"
                            case .zenlessZone: "zzz_note_vitality"
                            }
                            WatchAccountDetailItemView(
                                title: titleKey,
                                value: "\(sitrep.finished) / \(sitrep.all)",
                                icon: AccountKit.imageAsset(dailyTaskIcon)
                            )
                            Divider()
                        }

                        switch data {
                        case let data as any Note4GI:
                            WatchAccountDetailItemView(
                                title: "watch.dailyNote.card.homeCoin.label",
                                value: "\(data.homeCoinInfo.currentHomeCoin)",
                                icon: AccountKit.imageAsset("gi_note_teapot_coin")
                            )
                            Divider()
                            let expeditionIntel = data.expeditionCompletionStatus
                            WatchAccountDetailItemView(
                                title: "watch.dailyNote.card.expedition.label",
                                value: "\(expeditionIntel.finished) / \(expeditionIntel.all)",
                                icon: AccountKit.imageAsset("gi_note_expedition")
                            )
                            if let data = data as? GeneralNote4GI {
                                Divider()
                                WatchAccountDetailItemView(
                                    title: "watch.dailyNote.card.transformer",
                                    value: intervalFormatter
                                        .string(
                                            from: TimeInterval
                                                .sinceNow(to: data.transformerInfo.recoveryTime)
                                        )!,
                                    icon: AccountKit.imageAsset("gi_note_transformer")
                                )
                                Divider()
                                WatchAccountDetailItemView(
                                    title: "watch.dailyNote.card.weeklyBosses",
                                    value: data.weeklyBossesInfo.textDescription,
                                    icon: AccountKit.imageAsset("gi_note_weeklyBosses")
                                )
                            }
                        case let data as Note4HSR:
                            WatchAccountDetailItemView(
                                title: "watch.dailyNote.card.simulatedUniverse.label",
                                value: "\(data.simulatedUniverseInfo.currentScore) / \(data.simulatedUniverseInfo.maxScore)",
                                icon: AccountKit.imageAsset("hsr_note_simulatedUniverse")
                            )
                            Divider()
                            let expeditionIntel = data.expeditionCompletionStatus
                            WatchAccountDetailItemView(
                                title: "watch.dailyNote.card.expedition.label",
                                value: "\(expeditionIntel.finished) / \(expeditionIntel.all)",
                                icon: AccountKit.imageAsset("hsr_note_expedition")
                            )
                            if let eowIntel = data.echoOfWarIntel {
                                Divider()
                                WatchAccountDetailItemView(
                                    title: "watch.dailyNote.card.hsrEchoOfWar.label",
                                    value: eowIntel.textDescription,
                                    icon: AccountKit.imageAsset("hsr_note_weeklyBosses")
                                )
                            }
                        case _ as Note4ZZZ:
                            EmptyView()
                        // TODO: 絕區零的其他內容擴充。
                        default: EmptyView()
                        }
                    }
                }
            }
        }
        .navigationTitle(accountName ?? "")
    }

    @ViewBuilder var expeditionsList: some View {
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
        .foregroundColor(Color("textColor3"))
        .padding(.trailing)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .opacity(0.3)
                    .frame(width: g.size.width, height: g.size.height)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
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

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
