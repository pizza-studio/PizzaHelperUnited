// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetRectangular

@available(macOS, unavailable)
struct LockScreenResinWidgetRectangular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(verbatim: "\(staminaIntel.finished)")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor)
                        if staminaIntel.isAccomplished {
                            Text("pzWidgetsKit.stamina.full", bundle: .main)
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(
                                "pzWidgetsKit.infoBlock.refilledAt:\(PZWidgets.dateFormatter.string(from: data.staminaFullTimeOnFinish))",
                                bundle: .main
                            )
                            .lineLimit(2)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            case .failure:
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(Image(systemSymbol: .ellipsis))
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(.cyan)
                        Text(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
            }
        default:
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(verbatim: "\(staminaIntel.finished)")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .foregroundColor(.primary)
                        .widgetAccentable()
                        if staminaIntel.isAccomplished {
                            Text("pzWidgetsKit.stamina.full", bundle: .main)
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                        } else {
                            Text(
                                "pzWidgetsKit.infoBlock.refilledAt:\(PZWidgets.dateFormatter.string(from: data.staminaFullTimeOnFinish))",
                                bundle: .main
                            )
                            .lineLimit(2)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            case .failure:
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text(Image(systemSymbol: .ellipsis))
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        Text(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - FitSystemFont

struct FitSystemFont: ViewModifier {
    var lineLimit: Int
    var minimumScaleFactor: CGFloat
    var percentage: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .font(.system(size: min(
                    geometry.size.width,
                    geometry.size.height
                ) * percentage))
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor)
                .position(
                    x: geometry.frame(in: .local).midX,
                    y: geometry.frame(in: .local).midY
                )
        }
    }
}

extension View {
    @ViewBuilder
    func fitSystemFont(
        lineLimit: Int = 1,
        minimumScaleFactor: CGFloat = 0.01,
        percentage: CGFloat = 1
    )
        -> ModifiedContent<Self, FitSystemFont> {
        modifier(FitSystemFont(
            lineLimit: lineLimit,
            minimumScaleFactor: minimumScaleFactor,
            percentage: percentage
        ))
    }
}
