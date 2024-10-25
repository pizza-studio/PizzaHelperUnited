// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI

struct WeeklyBossesInfoBar: View {
    let weeklyBossesInfo: GeneralNote4GI.WeeklyBossesInfo4GI

    var isWeeklyBossesFinishedImage: some View {
        (weeklyBossesInfo.remainResinDiscount == weeklyBossesInfo.totalResinDiscount)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(1.0, scaler: 0.70)
            : Image(systemSymbol: .questionmark)
            .overlayImageWithRingProgressBar(1.0)
    }

    @MainActor var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("征讨领域")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isWeeklyBossesFinishedImage
                .frame(width: 13, height: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(weeklyBossesInfo.remainResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(weeklyBossesInfo.totalResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
