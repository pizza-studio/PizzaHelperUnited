// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetRectangular

struct LockScreenResinWidgetRectangular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(Color("iconColor.resin.middle"))
                        if data.resinInfo.calculatedCurrentResin(referTo: entry.date) >= data.resinInfo
                            .maxResin {
                            Text("widget.resin.full")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text(
                                "infoBlock.refilledAt:\(dateFormatter.string(from: data.resinInfo.resinRecoveryTime))"
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
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        .foregroundColor(.cyan)
                        Text(Image("icon.resin"))
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
            }
        default:
            switch result {
            case let .success(data):
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 40
                            Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                                .font(.system(size: size, design: .rounded))
                                .minimumScaleFactor(0.5)
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .foregroundColor(.primary)
                        .widgetAccentable()
                        if data.resinInfo.calculatedCurrentResin(referTo: entry.date) >= data.resinInfo
                            .maxResin {
                            Text("widget.resin.full")
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                        } else {
                            Text(
                                "infoBlock.refilledAt:\(dateFormatter.string(from: data.resinInfo.resinRecoveryTime))"
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
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: size * 1 / 2))
                                .minimumScaleFactor(0.5)
                        }
                        .widgetAccentable()
                        Text(Image("icon.resin"))
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

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
