// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct DailyTaskInfoBar: View {
    // MARK: Lifecycle

    init(dailyNote: any DailyNoteProtocol) {
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            dailyNote.game.dailyTaskAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isTaskRewardReceivedImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    let sitrep = dailyNote.dailyTaskCompletionStatus
                    Text(verbatim: "\(sitrep.finished)")
                    Text(verbatim: " / \(sitrep.all)")
                    if sitrep.isAccomplished,
                       let extraRewardClaimed = dailyNote.claimedRewardsFromKatheryne,
                       !extraRewardClaimed {
                        Text("pzWidgetsKit.status.not_received", bundle: .main)
                    }
                }
                .lineLimit(1)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
            .legibilityShadow()
        }
    }

    // MARK: Private

    private let dailyNote: any DailyNoteProtocol

    @ViewBuilder private var isTaskRewardReceivedImage: some View {
        if dailyNote.hasDailyTaskIntel {
            let sitrep = dailyNote.dailyTaskCompletionStatus
            let ratio = Double(sitrep.finished) / Double(sitrep.all)
            Group {
                if sitrep.isAccomplished {
                    if let extraRewardClaimed = dailyNote.claimedRewardsFromKatheryne {
                        Image(systemSymbol: extraRewardClaimed ? .checkmark : .exclamationmark)
                            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
                    } else {
                        Image(systemSymbol: .checkmark)
                            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
                    }
                } else {
                    Image(systemSymbol: .ellipsis)
                        .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
                }
            }
        } else {
            EmptyView()
        }
    }
}
