// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI

struct DailyTaskInfoBar: View {
    let dailyTaskInfo: DailyTaskInformation

    var isTaskRewardReceivedImage: some View {
        if !dailyTaskInfo.isExtraRewardReceived {
            if dailyTaskInfo.finishedTaskCount == dailyTaskInfo.totalTaskCount {
                return Image(systemSymbol: .exclamationmark)
                    .overlayImageWithRingProgressBar(1.0, scaler: 0.78)
            } else {
                return Image(systemSymbol: .questionmark)
                    .overlayImageWithRingProgressBar(1.0)
            }
        } else {
            return Image(systemSymbol: .checkmark)
                .overlayImageWithRingProgressBar(1.0, scaler: 0.70)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("每日任务")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)

            isTaskRewardReceivedImage

                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(dailyTaskInfo.finishedTaskCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(dailyTaskInfo.totalTaskCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                if !dailyTaskInfo.isExtraRewardReceived,
                   dailyTaskInfo.finishedTaskCount == dailyTaskInfo.totalTaskCount {
                    Text("widget.status.not_received")
                        .foregroundColor(Color("textColor3"))
                        .font(.system(.caption, design: .rounded))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                }
            }
        }
    }
}
