// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

// MARK: - ZZZBountyInfoBar

@available(watchOS, unavailable)
struct ZZZBountyInfoBar: View {
    // MARK: Lifecycle

    public init?(data: Note4ZZZ) {
        guard let validData = data.hollowZero.bountyCommission else { return nil }
        self.data = validData
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.zenlessZone.zzzBountyAssetIcon
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            ringImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    Text(verbatim: "\(data.num) / \(data.total)")
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

    private let data: Note4ZZZ.HollowZero.BountyCommission

    @ViewBuilder private var ringImage: some View {
        Image(systemSymbol: .dotScope)
            .overlayImageWithRingProgressBar(
                Double(data.num) / Double(data.total),
                scaler: 0.78
            )
    }
}
