// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

// MARK: - GITransformerInfoBar

@available(watchOS, unavailable)
struct GITransformerInfoBar: View {
    // MARK: Lifecycle

    init(transformerInfo: FullNote4GI.TransformerInfo4GI) {
        self.transformerInfo = transformerInfo
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.genshinImpact.giTransformerAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isTransformerCompleteImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
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
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .lineLimit(1)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
            .legibilityShadow(isText: false)
        }
    }

    // MARK: Private

    private let transformerInfo: FullNote4GI.TransformerInfo4GI

    @ViewBuilder private var isTransformerCompleteImage: some View {
        (transformerInfo.isAvailable)
            ? Image(systemSymbol: .checkmark)
            .overlayImageWithRingProgressBar(transformerInfo.percentage, scaler: 0.78)
            : Image(systemSymbol: .hourglass)
            .overlayImageWithRingProgressBar(0.78)
    }
}
