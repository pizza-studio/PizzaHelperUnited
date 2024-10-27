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
                        switch data {
                        case let data as GeneralNote4GI:
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.dailyTask.label",
                                value: "\(data.dailyTaskInfo.finishedTaskCount) / \(data.dailyTaskInfo.totalTaskCount)",
                                icon: Image("每日任务")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.homeCoin.label",
                                value: "\(data.homeCoinInfo.currentHomeCoin)",
                                icon: Image("洞天宝钱")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.transformer",
                                value: intervalFormatter
                                    .string(
                                        from: TimeInterval
                                            .sinceNow(to: data.transformerInfo.recoveryTime)
                                    )!,
                                icon: Image("参量质变仪")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.weeklyBoss",
                                value: "\(data.weeklyBossesInfo.remainResinDiscount) / \(data.weeklyBossesInfo.totalResinDiscount)",
                                icon: Image("征讨领域")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.expedition.label",
                                value: "\(data.expeditions.ongoingExpeditionCount) / \(data.expeditions.maxExpeditionsCount)",
                                icon: Image("派遣探索")
                            )
                        case let data as WidgetNote4GI:
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.dailyTask.label",
                                value: "\(data.dailyTaskInfo.finishedTaskCount) / \(data.dailyTaskInfo.totalTaskCount)",
                                icon: Image("每日任务")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.homeCoin.label",
                                value: "\(data.homeCoinInfo.currentHomeCoin)",
                                icon: Image("洞天宝钱")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.expedition.label",
                                value: "\(data.expeditions.ongoingExpeditionCount) / \(data.expeditions.maxExpeditionsCount)",
                                icon: Image("派遣探索")
                            )
                        case let data as GeneralNote4HSR:
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.expedition.label",
                                value: "\(data.assignmentInfo.onGoingAssignmentNumber) / \(data.assignmentInfo.totalAssignmentNumber)",
                                icon: Image("派遣探索")
                            )
                        case let data as WidgetNote4HSR:
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.dailyTask.label",
                                value: "\(data.dailyTrainingInfo.currentScore) / \(data.dailyTrainingInfo.maxScore)",
                                icon: Image("每日任务")
                            )
                            Divider()
                            WatchAccountDetailItemView(
                                title: "app.dailynote.card.expedition.label",
                                value: "\(data.assignmentInfo.onGoingAssignmentNumber) / \(data.assignmentInfo.totalAssignmentNumber)",
                                icon: Image("派遣探索")
                            )
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

    @MainActor @ViewBuilder var expeditionsList: some View {
        switch data {
        case let data as any Note4GI:
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                ForEach(
                    data.expeditions.expeditions,
                    id: \.iconURL
                ) { expedition in
                    WatchEachExpeditionView(
                        expedition: expedition,
                        useAsyncImage: true
                    )
                    .frame(maxHeight: 40)
                }
            }
        case let data as Note4HSR:
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                ForEach(
                    data.assignmentInfo.assignments,
                    id: \.iconURL
                ) { expedition in
                    WatchEachExpeditionView(
                        expedition: expedition,
                        useAsyncImage: true
                    )
                    .frame(maxHeight: 40)
                }
            }
        case _ as Note4ZZZ:
            EmptyView()
        default: EmptyView()
        }
    }
}

// MARK: - WatchEachExpeditionView

private struct WatchEachExpeditionView: View {
    let expedition: any Expedition
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
            if let expedition = expedition as? GeneralNote4GI.ExpeditionInfo4GI.Expedition {
                VStack(alignment: .leading) {
                    Text(intervalFormatter.string(from: TimeInterval.sinceNow(to: expedition.finishTime))!)
                        .font(.footnote)
                    percentageBar(TimeInterval.sinceNow(to: expedition.finishTime) / Double(20 * 60 * 60))
                }
            } else {
                VStack(alignment: .leading) {
                    Text(expedition.isFinished ? "watch.finished" : "watch.pending", bundle: .module)
                        .font(.footnote)
                    percentageBar(expedition.isFinished ? 0 : 1)
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
