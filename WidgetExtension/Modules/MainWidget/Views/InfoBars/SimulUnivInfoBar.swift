// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI

// MARK: - SimulUnivInfoBar

@available(watchOS, unavailable)
struct SimulUnivInfoBar: View {
    let dailyNote: any DailyNoteProtocol

    var isSimulUnivAllCompleteImage: some View {
        Image(systemSymbol: .ellipsis)
            .overlayImageWithRingProgressBar(
                1,
                scaler: 1,
                offset: (0.3, 0)
            )
    }

    var body: some View {
        switch dailyNote {
        case let dailyNote as WidgetNote4HSR:
            HStack(alignment: .center, spacing: 8) {
                AccountKit.imageAsset("hsr_note_simulatedUniverse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .shadow(color: .white, radius: 1)
                isSimulUnivAllCompleteImage
                    .frame(maxWidth: 13, maxHeight: 13)
                    .foregroundColor(Color("textColor3", bundle: .main))
                let intel = dailyNote.simulatedUniverseInfo
                Text(verbatim: "\(intel.currentScore) / \(intel.maxScore)")
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
