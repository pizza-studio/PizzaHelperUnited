// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetCorner

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenHomeCoinWidgetCorner: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG
                .resizable()
                .scaledToFit()
                .padding(3)
                .widgetLabel(text)
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let entry: any TimelineEntry
        private let result: Result<any DailyNoteProtocol, any Error>

        private var text: String {
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    let currentAmount = data.homeCoinInfo.currentHomeCoin
                    let fullTimeDescription = HoYo.formattedInterval(until: data.homeCoinInfo.fullTime)
                    return "\(currentAmount), \(fullTimeDescription)"
                default:
                    return "GENSHIN\nONLY"
                }
            case .failure:
                return String(
                    localized: String.LocalizationValue(stringLiteral: "pzWidgetsKit.homeCoin"),
                    bundle: .currentSPM
                )
            }
        }
    }
}

#endif
