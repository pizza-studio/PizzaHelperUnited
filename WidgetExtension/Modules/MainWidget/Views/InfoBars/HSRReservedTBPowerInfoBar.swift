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
struct HSRReservedTBPowerInfoBar: View {
    // MARK: Lifecycle

    init(tbPowerIntel: StaminaInfo4HSR) {
        self.tbPowerIntel = tbPowerIntel
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.starRail.secondaryStaminaAssetIcon
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            isReservedTrailblazePowerFullImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(verbatim: "\(tbPowerIntel.currentReserveStamina)")
                    .lineLimit(1)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .legibilityShadow()
            }
        }
    }

    // MARK: Private

    private let tbPowerIntel: StaminaInfo4HSR

    @ViewBuilder private var isReservedTrailblazePowerFullImage: some View {
        (tbPowerIntel.currentReserveStamina == tbPowerIntel.maxReserveStamina)
            ? Image(systemSymbol: .exclamationmark)
            .overlayImageWithRingProgressBar(
                Double(tbPowerIntel.currentReserveStamina) / Double(tbPowerIntel.maxReserveStamina),
                scaler: 0.78
            )
            : Image(systemSymbol: .leafFill)
            .overlayImageWithRingProgressBar(
                Double(tbPowerIntel.currentReserveStamina) / Double(tbPowerIntel.maxReserveStamina),
                scaler: 0.78
            )
    }
}
