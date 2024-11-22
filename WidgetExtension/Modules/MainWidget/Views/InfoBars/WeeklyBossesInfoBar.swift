// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct WeeklyBossesInfoBar: View {
    let weeklyBossesInfo: GeneralNote4GI.WeeklyBossesInfo4GI

    var isWeeklyBossesFinishedImage: some View {
        (weeklyBossesInfo.remainResinDiscount == 0)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(1.0, scaler: 0.70)
            : Image(systemSymbol: .questionmark)
            .overlayImageWithRingProgressBar(1.0)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset("gi_note_weeklyBosses")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isWeeklyBossesFinishedImage
                .frame(width: 13, height: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: "\(weeklyBossesInfo.remainResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(verbatim: " / \(weeklyBossesInfo.totalResinDiscount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.footnote, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
            .legibilityShadow(isText: false)
        }
    }
}
