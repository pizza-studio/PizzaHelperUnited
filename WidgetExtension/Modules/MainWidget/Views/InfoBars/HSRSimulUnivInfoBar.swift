// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

// MARK: - HSRSimulUnivInfoBar

@available(watchOS, unavailable)
struct HSRSimulUnivInfoBar: View {
    // MARK: Lifecycle

    init(dailyNote: any Note4HSR) {
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    @ViewBuilder var body: some View {
        let intel = dailyNote.simulatedUniverseInfo
        let currentScore = intel.currentScore
        let maxScore = intel.maxScore
        let isFinished = currentScore == maxScore
        HStack(alignment: .center, spacing: 8) {
            dailyNote.game.hsrSimulatedUniverseAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            let ratio = (Double(currentScore) / Double(maxScore) * 100).rounded(.down)
            Image(systemSymbol: isFinished ? .checkmark : .ellipsis)
                .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            Text(verbatim: "\(ratio)%")
                .lineLimit(1)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
                .legibilityShadow()
        }
    }

    // MARK: Private

    private let dailyNote: any Note4HSR
}
