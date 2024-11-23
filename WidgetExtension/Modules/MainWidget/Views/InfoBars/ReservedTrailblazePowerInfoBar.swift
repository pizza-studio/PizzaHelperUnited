// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(watchOS, unavailable)
struct ReservedTrailblazePowerInfoBar: View {
    let tbPowerIntel: StaminaInfo4HSR

    var isReservedTrailblazePowerFullImage: some View {
        (tbPowerIntel.currentReserveStamina == tbPowerIntel.maxReserveStamina)
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                Double(tbPowerIntel.currentReserveStamina) / Double(tbPowerIntel.maxReserveStamina),
                scaler: 0.78
            )
            : Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(
                Double(tbPowerIntel.currentReserveStamina) / Double(tbPowerIntel.maxReserveStamina)
            )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AccountKit.imageAsset("hsr_note_trailblazePowerReserved")
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isReservedTrailblazePowerFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: "\(tbPowerIntel.currentReserveStamina)")
                    .lineLimit(1)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .legibilityShadow()
            }
        }
    }
}
