// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI

struct ExpeditionInfoBar: View {
    let expeditionInfo: any ExpeditionInformation

    var isExpeditionAllCompleteImage: some View {
        Image(systemSymbol: .figureWalk)
            .overlayImageWithRingProgressBar(
                1,
                scaler: 1,
                offset: (0.3, 0)
            )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("派遣探索")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isExpeditionAllCompleteImage

                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))

            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(expeditionInfo.ongoingExpeditionCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.body, design: .rounded))
                    .minimumScaleFactor(0.2)
                Text(" / \(expeditionInfo.maxExpeditionsCount)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3"))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
