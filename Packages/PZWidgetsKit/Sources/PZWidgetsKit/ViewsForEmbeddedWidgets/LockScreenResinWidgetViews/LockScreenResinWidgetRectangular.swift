// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - EmbeddedWidgets.LockScreenResinWidgetRectangular

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: - LockScreenResinWidgetRectangular

    public struct LockScreenResinWidgetRectangular: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
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
                                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
                                    .font(.system(size: size * 1 / 2))
                                    .minimumScaleFactor(0.5)
                            }
                            .widgetAccentable()
                            .foregroundColor(PZWidgetsSPM.Colors.IconColor.Resin.middle.suiColor)
                            if staminaIntel.isAccomplished {
                                Text("pzWidgetsKit.stamina.full", bundle: .module)
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text(
                                    "pzWidgetsKit.infoBlock.refilledAt:\(PZWidgetsSPM.dateFormatter.string(from: data.staminaFullTimeOnFinish))",
                                    bundle: .module
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
                                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
                                    .font(.system(size: size * 1 / 2))
                                    .minimumScaleFactor(0.5)
                            }
                            .widgetAccentable()
                            .foregroundColor(.cyan)
                            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
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
                                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
                                    .font(.system(size: size * 1 / 2))
                                    .minimumScaleFactor(0.5)
                            }
                            .foregroundColor(.primary)
                            .widgetAccentable()
                            if staminaIntel.isAccomplished {
                                Text("pzWidgetsKit.stamina.full", bundle: .module)
                                    .font(.footnote)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.gray)
                            } else {
                                Text(
                                    "pzWidgetsKit.infoBlock.refilledAt:\(PZWidgetsSPM.dateFormatter.string(from: data.staminaFullTimeOnFinish))",
                                    bundle: .module
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
                                Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
                                    .font(.system(size: size * 1 / 2))
                                    .minimumScaleFactor(0.5)
                            }
                            .widgetAccentable()
                            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaSVGAsInlineText
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
            }
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let entry: any TimelineEntry

        private let result: Result<any DailyNoteProtocol, any Error>
    }
}

// MARK: - FitSystemFont

private struct FitSystemFont: ViewModifier {
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
    private func fitSystemFont(
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

#endif
