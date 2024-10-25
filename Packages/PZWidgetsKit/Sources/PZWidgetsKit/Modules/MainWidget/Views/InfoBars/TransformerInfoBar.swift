// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI

// MARK: - TransformerInfoBar

struct TransformerInfoBar: View {
    let transformerInfo: GeneralNote4GI.TransformerInfo4GI

    var percentage: Double {
        let second = transformerInfo.recoveryTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        return second / Double(7 * 24 * 60 * 60)
    }

    var isTransformerCompleteImage: some View {
        (transformerInfo.recoveryTime <= Date())
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                percentage,
                scaler: 0.78
            )
            : Image(systemSymbol: .hourglass)
            .overlayImageWithRingProgressBar(1)
    }

    @MainActor var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("参量质变仪")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTransformerCompleteImage

                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3"))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(
                    PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: transformerInfo.recoveryTime))!
                )
                .foregroundColor(Color("textColor3"))
                .lineLimit(1)
                .font(.system(.body, design: .rounded))
                .minimumScaleFactor(0.2)
            }
        }
    }
}
