// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

// MARK: - ZZZScratchCardInfoBar

@available(watchOS, unavailable)
struct ZZZScratchCardInfoBar: View {
    // MARK: Lifecycle

    public init?(data: Note4ZZZ) {
        guard let scratched = data.cardScratched else { return nil }
        self.scratchable = !scratched
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.zenlessZone.zzzScratchCardAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            ringImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    Text(statusText)
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

    private let scratchable: Bool

    private var statusText: String {
        let key: String.LocalizationValue = switch scratchable {
        case true: "pzWidgetsKit.infoBlock.zzzScratchableCard.notYet"
        case false: "pzWidgetsKit.infoBlock.zzzScratchableCard.done"
        }
        return String(localized: key, bundle: .main)
    }

    @ViewBuilder private var ringImage: some View {
        Image(systemSymbol: .giftcardFill)
            .overlayImageWithRingProgressBar(
                scratchable ? 0.0 : 1.0, scaler: 0.78
            )
    }
}
