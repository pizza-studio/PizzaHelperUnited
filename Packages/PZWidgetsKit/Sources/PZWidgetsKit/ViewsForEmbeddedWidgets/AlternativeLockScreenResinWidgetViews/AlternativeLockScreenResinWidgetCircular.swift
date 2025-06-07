// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
extension EmbeddedWidgets {
    @available(macOS, unavailable)
    public struct AlternativeLockScreenResinWidgetCircular: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
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

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let entry: any TimelineEntry
        private let result: Result<any DailyNoteProtocol, any Error>
    }
}
