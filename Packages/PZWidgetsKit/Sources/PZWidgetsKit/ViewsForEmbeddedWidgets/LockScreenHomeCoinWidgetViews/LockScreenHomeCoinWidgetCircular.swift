// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenHomeCoinWidgetCircular: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            VStack(spacing: 0) {
                Pizza.SupportedGame.genshinImpact.giRealmCurrencyAsset4Embedded
                    .apply { imageView in
                        if widgetRenderingMode == .fullColor {
                            imageView
                                .foregroundColor(PZWidgetsSPM.Colors.IconColor.HomeCoin.lightBlue.suiColor)
                        } else {
                            imageView
                        }
                    }
                switch result {
                case let .success(data):
                    switch data {
                    case let data as any Note4GI:
                        Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
                            .font(.system(.body, design: .rounded).weight(.medium))
                    default:
                        Text(verbatim: "GENSHIN\nONLY")
                            .fontWidth(.compressed)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.2)
                    }
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

#endif
