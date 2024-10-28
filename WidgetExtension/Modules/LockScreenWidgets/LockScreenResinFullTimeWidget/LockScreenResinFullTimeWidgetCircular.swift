// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinFullTimeWidgetCircular

@available(macOS, unavailable)
struct LockScreenResinFullTimeWidgetCircular: View {
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
        switch widgetRenderingMode {
        case .fullColor:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: -0.5) {
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
                        Image(staminaMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                    )
                    .frame(height: 9)
                    switch result {
                    case let .success(data):
                        switch data {
                        case let data as any Note4GI:
                            VStack(spacing: -2) {
                                if data.resinInfo.currentResinDynamic != data
                                    .resinInfo.maxResin {
                                    Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                        .font(.system(
                                            size: 20,
                                            weight: .medium,
                                            design: .rounded
                                        ))
                                        .widgetAccentable()
                                    let dateString: String = {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        formatter
                                            .locale =
                                            Locale(identifier: "en_US_POSIX")
                                        return formatter
                                            .string(
                                                from: Date(
                                                    timeIntervalSinceNow: TimeInterval
                                                        .sinceNow(to: data.resinInfo.resinRecoveryTime)
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
                                    Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                        .font(.system(
                                            size: 20,
                                            weight: .medium,
                                            design: .rounded
                                        ))
                                        .widgetAccentable()
                                }
                            }
                        default:
                            Image(staminaMonochromeIconAssetName, bundle: .main)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                            Image(systemSymbol: .ellipsis)
                        }
                    case .failure:
                        Image(staminaMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
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
                    Image(staminaMonochromeIconAssetName, bundle: .main)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 9)
                    switch result {
                    case let .success(data):
                        switch data {
                        case let data as any Note4GI:
                            VStack(spacing: -2) {
                                if data.resinInfo.currentResinDynamic != data
                                    .resinInfo.maxResin {
                                    Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                        .font(.system(
                                            size: 20,
                                            weight: .medium,
                                            design: .rounded
                                        ))
                                        .widgetAccentable()
                                    let dateString: String = {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "HH:mm"
                                        return formatter
                                            .string(
                                                from: Date(
                                                    timeIntervalSinceNow: TimeInterval
                                                        .sinceNow(to: data.resinInfo.resinRecoveryTime)
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
                                    Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                        .font(.system(
                                            size: 20,
                                            weight: .medium,
                                            design: .rounded
                                        ))
                                        .widgetAccentable()
                                }
                            }
                        default:
                            Image(staminaMonochromeIconAssetName, bundle: .main)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 10)
                            Image(systemSymbol: .ellipsis)
                        }
                    case .failure:
                        Image(staminaMonochromeIconAssetName, bundle: .main)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
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
}

// MARK: - MyContainerBackground

private struct MyContainerBackground<B: View>: ViewModifier {
    let background: () -> B

    func body(content: Content) -> some View {
        if #available(iOS 17.0, iOSApplicationExtension 17.0, watchOS 10.0, *) {
            content.containerBackground(for: .widget) {
                background()
            }
        } else {
            content
                .background {
                    background()
                }
        }
    }
}

extension View {
    func lockscreenContainerBackground(@ViewBuilder _ background: @escaping () -> some View) -> some View {
        modifier(MyContainerBackground(background: background))
    }
}
