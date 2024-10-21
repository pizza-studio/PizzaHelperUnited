// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct LockScreenResinTimerWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

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
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                    )
                    .frame(height: 10)
                    switch result {
                    case let .success(data):
                        VStack(spacing: 1) {
                            if data.resinInfo.calculatedCurrentResin(referTo: entry.date) != data
                                .resinInfo.maxResin {
                                Text(
                                    Date(
                                        timeIntervalSinceNow: TimeInterval
                                            .sinceNow(to: data.resinInfo.resinRecoveryTime)
                                    ),
                                    style: .timer
                                )
                                .multilineTextAlignment(.center)
                                .font(.system(.body, design: .monospaced))
                                .minimumScaleFactor(0.1)
                                .widgetAccentable()
                                .frame(width: 50)
                                Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                            } else {
                                Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .foregroundColor(
                                        Color("textColor.originResin")
                                    )
                            }
                        }
                    case .failure:
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
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
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                    switch result {
                    case let .success(data):
                        VStack(spacing: 1) {
                            if data.resinInfo.calculatedCurrentResin(referTo: entry.date) != data
                                .resinInfo.maxResin {
                                Text(
                                    Date(
                                        timeIntervalSinceNow: TimeInterval
                                            .sinceNow(to: data.resinInfo.resinRecoveryTime)
                                    ),
                                    style: .timer
                                )
                                .multilineTextAlignment(.center)
                                .font(.system(.body, design: .monospaced))
                                .minimumScaleFactor(0.1)
                                .widgetAccentable()
                                .frame(width: 50)
                                Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                    .font(.system(
                                        .body,
                                        design: .rounded,
                                        weight: .medium
                                    ))
                            } else {
                                Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                        }
                    case .failure:
                        Image("icon.resin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
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
