// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct HSREchoOfWarInfoBar: View {
    // MARK: Lifecycle

    init(eowIntel: EchoOfWarInfo4HSR) {
        self.eowIntel = eowIntel
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.starRail.hsrEchoOfWarAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isWeeklyBossesFinishedImage
                .frame(width: 13, height: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: eowIntel.textDescription)
                    .lineLimit(1)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
            .legibilityShadow(isText: false)
        }
    }

    // MARK: Private

    private let eowIntel: EchoOfWarInfo4HSR

    @ViewBuilder private var isWeeklyBossesFinishedImage: some View {
        let current = eowIntel.weeklyEOWMaxRewards - eowIntel.weeklyEOWRewardsLeft
        let max = eowIntel.weeklyEOWMaxRewards
        let ratio = Double(current) / Double(max)
        (eowIntel.allRewardsClaimed)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
            : Image(systemSymbol: .questionmark)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
    }
}
