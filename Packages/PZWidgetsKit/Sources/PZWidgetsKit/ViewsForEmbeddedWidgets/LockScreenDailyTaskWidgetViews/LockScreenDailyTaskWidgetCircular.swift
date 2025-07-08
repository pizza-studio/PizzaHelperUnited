// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenDailyTaskWidgetCircular: View {
        // MARK: Lifecycle

        public init(result: Result<any DailyNoteProtocol, any Error>) {
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            VStack(spacing: 0) {
                Pizza.SupportedGame(dailyNoteResult: result).dailyTaskAssetSVG
                    .resizable()
                    .scaledToFit()
                    .apply { imageView in
                        if widgetRenderingMode == .fullColor {
                            imageView
                                .foregroundColor(PZWidgetsSPM.Colors.IconColor.dailyTask.suiColor)
                        } else {
                            imageView
                        }
                    }
                switch result {
                case let .success(data):
                    if data.hasDailyTaskIntel {
                        let sitrep = data.dailyTaskCompletionStatus
                        Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
                            .font(.system(.body, design: .rounded).weight(.medium))
                    } else {
                        Text(verbatim: "NOT 4\nZZZ")
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

        private let result: Result<any DailyNoteProtocol, any Error>
    }
}

#endif
