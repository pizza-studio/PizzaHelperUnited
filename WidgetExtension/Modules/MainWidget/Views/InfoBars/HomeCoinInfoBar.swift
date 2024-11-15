// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
struct HomeCoinInfoBar: View {
    let entry: any TimelineEntry
    let homeCoinInfo: PZAccountKit.HomeCoinInfo4GI

    var isHomeCoinFullImage: some View {
        (homeCoinInfo.currentHomeCoin == homeCoinInfo.maxHomeCoin)
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                Double(homeCoinInfo.currentHomeCoin) / Double(homeCoinInfo.maxHomeCoin),
                scaler: 0.78
            )
            : Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(
                Double(homeCoinInfo.currentHomeCoin) /
                    Double(homeCoinInfo.maxHomeCoin)
            )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset("gi_note_teapot_coin")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
            isHomeCoinFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: "\(homeCoinInfo.currentHomeCoin)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
            }
        }
    }
}
