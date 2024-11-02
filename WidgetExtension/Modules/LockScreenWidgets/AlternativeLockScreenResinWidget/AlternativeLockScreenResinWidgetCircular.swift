// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct AlternativeLockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var staminaMonochromeIconAssetName: String {
        switch result {
        case let .success(data):
            return switch data.game {
            case .genshinImpact: "icon.resin"
            case .starRail: "icon.trailblazePower"
            case .zenlessZone: "icon.zzzBattery"
            }
        case .failure: return "icon.resin"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            let img = Image(staminaMonochromeIconAssetName, bundle: .main)
                .resizable()
                .scaledToFit()
            switch widgetRenderingMode {
            case .fullColor:
                LinearGradient(
                    colors: [
                        .init("iconColor.resin.dark"),
                        .init("iconColor.resin.middle"),
                        .init("iconColor.resin.light"),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(img)
            default:
                img
            }
            // ------------
            switch result {
            case let .success(data):
                Text(verbatim: "\(data.staminaIntel.existing)")
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .minimumScaleFactor(0.1)
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
        .widgetAccentable(widgetRenderingMode == .accented)
        #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
        #else
            .padding(.vertical, 2)
        #endif
    }
}
