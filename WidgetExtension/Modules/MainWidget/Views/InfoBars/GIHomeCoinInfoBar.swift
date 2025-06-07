// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
struct GIHomeCoinInfoBar: View {
    // MARK: Lifecycle

    init(homeCoinInfo: any PZAccountKit.HomeCoinInfo4GI) {
        self.homeCoinInfo = homeCoinInfo
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetIcon
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isHomeCoinFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: "\(homeCoinInfo.currentHomeCoin)")
                    .lineLimit(1)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .legibilityShadow()
            }
        }
    }

    // MARK: Private

    private let homeCoinInfo: any PZAccountKit.HomeCoinInfo4GI

    @ViewBuilder private var isHomeCoinFullImage: some View {
        let ratio = Double(homeCoinInfo.currentHomeCoin) / Double(homeCoinInfo.maxHomeCoin)
        (homeCoinInfo.currentHomeCoin == homeCoinInfo.maxHomeCoin)
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
            : Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
    }
}
