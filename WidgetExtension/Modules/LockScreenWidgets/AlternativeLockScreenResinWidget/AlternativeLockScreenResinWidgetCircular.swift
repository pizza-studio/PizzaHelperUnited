// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct AlternativeLockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        VStack(spacing: 0) {
            let game = (Pizza.SupportedGame(dailyNoteResult: result) ?? .genshinImpact)
            let img = game.primaryStaminaAssetSVG
                .resizable()
                .scaledToFit()
            switch widgetRenderingMode {
            case .fullColor:
                LinearGradient(
                    colors: [
                        PZWidgetsSPM.Colors.IconColor.Resin.dark.suiColor,
                        PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor,
                        PZWidgetsSPM.Colors.IconColor.Resin.light.suiColor,
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
                Text(verbatim: "\(data.staminaIntel.finished)")
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
