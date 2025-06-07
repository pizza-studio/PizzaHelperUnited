// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinFullTimeWidgetCircular

@available(macOS, unavailable)
public struct LockScreenResinFullTimeWidgetCircular: View {
    // MARK: Lifecycle

    public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
        self.entry = entry
        self.result = result
    }

    // MARK: Public

    public let entry: any TimelineEntry

    public var body: some View {
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
                        VStack(spacing: -2) {
                            if staminaIntel.finished != staminaIntel.all {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .minimumScaleFactor(0.1)
                                    .widgetAccentable()
                                let dateString: String = {
                                    // 此处强制使用 POSIX 区域。
                                    let formatter = DateFormatter.GregorianPOSIX()
                                    formatter.dateFormat = "HH:mm"
                                    return formatter
                                        .string(
                                            from: Date(
                                                timeIntervalSinceNow: TimeInterval
                                                    .sinceNow(to: timeOnFinish)
                                            )
                                        )
                                }()
                                Text(dateString)
                                    .font(.system(
                                        .caption,
                                        design: .monospaced
                                    ))
                                    .minimumScaleFactor(0.1)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .widgetAccentable()
                            }
                        }
                    case .failure:
                        Image(systemSymbol: .ellipsis)
                    }
                }
                .padding(.vertical, 2)
                #if os(watchOS)
                    .padding(.vertical, 2)
                    .padding(.bottom, 1)
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
                        VStack(spacing: -2) {
                            if staminaIntel.finished != staminaIntel.all {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .minimumScaleFactor(0.1)
                                    .widgetAccentable()
                                let dateString: String = {
                                    // 此处强制使用 POSIX 区域。
                                    let formatter = DateFormatter.GregorianPOSIX()
                                    formatter.dateFormat = "HH:mm"
                                    return formatter
                                        .string(
                                            from: Date(
                                                timeIntervalSinceNow: TimeInterval
                                                    .sinceNow(to: timeOnFinish)
                                            )
                                        )
                                }()
                                Text(dateString)
                                    .font(.system(
                                        .caption,
                                        design: .monospaced
                                    ))
                                    .minimumScaleFactor(0.1)
                            } else {
                                Text(verbatim: "\(staminaIntel.finished)")
                                    .font(.system(
                                        size: 20,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                                    .widgetAccentable()
                            }
                        }
                    case .failure:
                        Image(systemSymbol: .ellipsis)
                    }
                }
                .padding(.vertical, 2)
                #if os(watchOS)
                    .padding(.vertical, 2)
                    .padding(.bottom, 1)
                #endif
            }
        }
    }

    // MARK: Private

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    private let result: Result<any DailyNoteProtocol, any Error>
}
