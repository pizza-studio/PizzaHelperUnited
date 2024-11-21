// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - TransformerInfoBar

@available(watchOS, unavailable)
struct TransformerInfoBar: View {
    let transformerInfo: GeneralNote4GI.TransformerInfo4GI

    var isTransformerCompleteImage: some View {
        (transformerInfo.isAvailable)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(
                transformerInfo.percentage,
                scaler: 0.78
            )
            : Image(systemSymbol: .hourglass)
            .overlayImageWithRingProgressBar(1)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset("gi_note_transformer")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isTransformerCompleteImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    if transformerInfo.isAvailable {
                        Text("pzWidgetsKit.infoBlock.transformerAvailable", bundle: .main)
                    } else {
                        let remainingDays = transformerInfo.remainingDays
                        if remainingDays > 0 {
                            Text("pzWidgetsKit.unit.day:\(remainingDays)", bundle: .main)
                        } else {
                            Text(
                                verbatim: PZWidgets.intervalFormatter.string(
                                    from: TimeInterval.sinceNow(
                                        to: transformerInfo.recoveryTime
                                    )
                                )!
                            )
                        }
                    }
                }
                .foregroundColor(Color("textColor3", bundle: .main))
                .lineLimit(1)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
        }
    }
}
