// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(iOS 17.0, macCatalyst 17.0, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: Lifecycle

    public struct LockScreenResinTimerWidgetCircular: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public let entry: any TimelineEntry

        public var body: some View {
            coreBody
                .trackCanvasSize { newSize in
                    canvasSize = newSize
                }
        }

        // MARK: Private

        @State private var canvasSize: CGSize = .zero

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let result: Result<any DailyNoteProtocol, any Error>

        private var textWidth: CGFloat {
            #if os(watchOS)
            0.8 * canvasSize.width
            #else
            0.6 * canvasSize.width
            #endif
        }

        @ViewBuilder private var coreBody: some View {
            switch widgetRenderingMode {
            case .fullColor:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: -0.5) {
                        LinearGradient(
                            colors: [
                                PZWidgetsSPM.Colors.IconColor.Resin.dark.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor,
                                PZWidgetsSPM.Colors.IconColor.Resin.light.suiColor,
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(
                            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                                .resizable()
                                .scaledToFit()
                        )
                        .frame(height: 9)
                        switch result {
                        case let .success(data):
                            let staminaIntel = data.staminaIntel
                            let timeOnFinish = data.staminaFullTimeOnFinish
                            if staminaIntel.finished != staminaIntel.all {
                                VStack(spacing: -2) {
                                    Text(
                                        Date(
                                            timeIntervalSinceNow: TimeInterval
                                                .sinceNow(to: timeOnFinish)
                                        ),
                                        style: .timer
                                    )
                                    .multilineTextAlignment(.center)
                                    .font(.system(.body, design: .monospaced))
                                    .minimumScaleFactor(0.1)
                                    .widgetAccentable()
                                    .frame(width: textWidth)
                                    Text(verbatim: "\(staminaIntel.finished)")
                                        .font(.system(
                                            .body,
                                            design: .rounded,
                                            weight: .medium
                                        ))
                                        .foregroundColor(
                                            PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                                        )
                                        .minimumScaleFactor(0.1)
                                }
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .foregroundColor(
                                        PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                                    )
                            }
                        case .failure:
                            Image(systemSymbol: .ellipsis)
                        }
                    }
                    .padding(.vertical, 2)
                    #if os(watchOS)
                        .padding(.vertical, 2)
                    #endif
                }
            default:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: -0.5) {
                        Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                            .resizable()
                            .scaledToFit()
                            .frame(height: 9)
                        switch result {
                        case let .success(data):
                            let staminaIntel = data.staminaIntel
                            let timeOnFinish = data.staminaFullTimeOnFinish
                            if staminaIntel.finished != staminaIntel.all {
                                VStack(spacing: -2) {
                                    Text(
                                        Date(
                                            timeIntervalSinceNow: TimeInterval
                                                .sinceNow(to: timeOnFinish)
                                        ),
                                        style: .timer
                                    )
                                    .multilineTextAlignment(.center)
                                    .font(.system(.body, design: .monospaced))
                                    .minimumScaleFactor(0.1)
                                    .widgetAccentable()
                                    .frame(width: textWidth)
                                    Text(verbatim: "\(staminaIntel.finished)")
                                        .font(.system(
                                            .body,
                                            design: .rounded,
                                            weight: .medium
                                        ))
                                        .minimumScaleFactor(0.1)
                                }
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                        case .failure:
                            Image(systemSymbol: .ellipsis)
                        }
                    }
                    .padding(.vertical, 2)
                    #if os(watchOS)
                        .padding(.vertical, 2)
                    #endif
                }
            }
        }
    }
}

#endif
