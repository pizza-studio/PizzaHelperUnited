// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct LockScreenResinTimerWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 3) {
                    LinearGradient(
                        colors: [
                            .init("iconColor.resin.dark"),
                            .init("iconColor.resin.middle"),
                            .init("iconColor.resin.light"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(
                        Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                            .resizable()
                            .scaledToFit()
                    )
                    .frame(height: 10)
                    switch result {
                    case let .success(data):
                        let staminaIntel = data.staminaIntel
                        let timeOnFinish = data.staminaFullTimeOnFinish
                        VStack(spacing: 1) {
                            if staminaIntel.finished != staminaIntel.all {
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
                                .frame(width: 50)
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin", bundle: .main)
                                    )
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin", bundle: .main)
                                    )
                            }
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
                VStack(spacing: 3) {
                    Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                    switch result {
                    case let .success(data):
                        let staminaIntel = data.staminaIntel
                        let timeOnFinish = data.staminaFullTimeOnFinish
                        VStack(spacing: 1) {
                            if staminaIntel.finished != staminaIntel.all {
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
                                .frame(width: 50)
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
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
