// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct DailyTaskInfoBar: View {
    let dailyNote: any DailyNoteProtocol

    @MainActor @ViewBuilder var isTaskRewardReceivedImage: some View {
        switch dailyNote {
        case let dailyNote as any Note4GI:
            let dailyTaskInfo = dailyNote.dailyTaskInfo
            if !dailyTaskInfo.isExtraRewardReceived {
                if dailyTaskInfo.finishedTaskCount == dailyTaskInfo.totalTaskCount {
                    Image(systemSymbol: .exclamationmark)
                        .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
                } else {
                    Image(systemSymbol: .questionmark)
                        .overlayImageWithRingProgressBar(1.0)
                }
            } else {
                Image(systemSymbol: .checkmark)
                    .overlayImageWithRingProgressBar(1.0, scaler: 0.70)
            }
        case let dailyNote as WidgetNote4HSR:
            let dailyTaskInfo = dailyNote.dailyTrainingInfo
            let allFinished = dailyTaskInfo.currentScore == dailyTaskInfo.maxScore
            Image(systemSymbol: allFinished ? .checkmark : .exclamationmark)
                .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
        case let dailyNote as Note4ZZZ: // Vitality
            let dailyTaskInfo = dailyNote.vitality
            let allFinished = dailyTaskInfo.current == dailyTaskInfo.max
            Image(systemSymbol: allFinished ? .checkmark : .exclamationmark)
                .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
        default: EmptyView()
        }
    }

    @MainActor var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset("gi_note_dailyTask")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTaskRewardReceivedImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    switch dailyNote {
                    case let dailyNote as any Note4GI:
                        let dailyTaskInfo = dailyNote.dailyTaskInfo
                        Text(verbatim: "\(dailyTaskInfo.finishedTaskCount)")
                        Text(verbatim: " / \(dailyTaskInfo.totalTaskCount)")
                        if !dailyTaskInfo.isExtraRewardReceived,
                           dailyTaskInfo.finishedTaskCount == dailyTaskInfo.totalTaskCount {
                            Text("pzWidgetsKit.status.not_received", bundle: .main)
                        }
                    case let dailyNote as WidgetNote4HSR:
                        let dailyTaskInfo = dailyNote.dailyTrainingInfo
                        Text(verbatim: "\(dailyTaskInfo.currentScore)")
                        Text(verbatim: " / \(dailyTaskInfo.maxScore)")
                    case let dailyNote as Note4ZZZ: // Vitality
                        let dailyTaskInfo = dailyNote.vitality
                        Text(verbatim: "\(dailyTaskInfo.current)")
                        Text(verbatim: " / \(dailyTaskInfo.max)")
                    default: EmptyView()
                    }
                }
                .lineLimit(1)
                .foregroundColor(Color("textColor3", bundle: .main))
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
        }
    }
}
