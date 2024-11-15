// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - SimulUnivInfoBar

@available(watchOS, unavailable)
struct SimulUnivInfoBar: View {
    let dailyNote: any DailyNoteProtocol

    var body: some View {
        switch dailyNote {
        case let dailyNote as WidgetNote4HSR:
            let intel = dailyNote.simulatedUniverseInfo
            let currentScore = intel.currentScore
            let maxScore = intel.maxScore
            let isFinished = currentScore == maxScore
            HStack(alignment: .center, spacing: 8) {
                AccountKit.imageAsset("hsr_note_simulatedUniverse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .shadow(color: .white, radius: 1)
                Image(systemSymbol: isFinished ? .checkmark : .ellipsis)
                    .overlayImageWithRingProgressBar(
                        1,
                        scaler: 1,
                        offset: (0.3, 0)
                    )
                    .frame(maxWidth: 13, maxHeight: 13)
                    .foregroundColor(Color("textColor3", bundle: .main))
                let ratio = (Double(currentScore) / Double(maxScore) * 100).rounded(.down)
                Text(verbatim: "\(ratio)%")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        default:
            EmptyView()
        }
    }
}
