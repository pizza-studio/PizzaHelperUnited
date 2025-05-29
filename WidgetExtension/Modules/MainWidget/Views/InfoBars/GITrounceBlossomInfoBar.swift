// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct GITrounceBlossomInfoBar: View {
    // MARK: Lifecycle

    init(weeklyBossesInfo: FullNote4GI.WeeklyBossesInfo4GI) {
        self.weeklyBossesInfo = weeklyBossesInfo
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.genshinImpact.giTrounceBlossomAssetIcon
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
                Text(verbatim: weeklyBossesInfo.textDescription)
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
            .legibilityShadow(isText: false)
        }
    }

    // MARK: Private

    private let weeklyBossesInfo: FullNote4GI.WeeklyBossesInfo4GI

    @ViewBuilder private var isWeeklyBossesFinishedImage: some View {
        let current = weeklyBossesInfo.totalResinDiscount - weeklyBossesInfo.remainResinDiscount
        let max = weeklyBossesInfo.totalResinDiscount
        let ratio = Double(current) / Double(max)
        (weeklyBossesInfo.allDiscountsAreUsedUp)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
            : Image(systemSymbol: .questionmark)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
    }
}
