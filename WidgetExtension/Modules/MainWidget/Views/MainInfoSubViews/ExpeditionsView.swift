// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ExpeditionsView

@available(watchOS, unavailable)
struct ExpeditionsView: View {
    let expeditions: [any ExpeditionTask]

    var body: some View {
        VStack {
            ForEach(expeditions, id: \.iconURL) { expedition in
                EachExpeditionView(expedition: expedition)
            }
        }
    }
}

// MARK: - EachExpeditionView

@available(watchOS, unavailable)
struct EachExpeditionView: View {
    let expedition: any ExpeditionTask
    let viewConfig: WidgetViewConfiguration = .defaultConfig

    var body: some View {
        HStack {
            webView(url: expedition.iconURL, copilotURL: expedition.iconURL4Copilot)
            VStack(alignment: .leading) {
                if !expedition.isFinished, let finishTime = expedition.timeOnFinish {
                    Text(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: finishTime))!)
                        .lineLimit(1)
                        .font(.caption2)
                        .minimumScaleFactor(0.4)
                        .legibilityShadow()
                    let totalSecond = 20.0 * 60.0 * 60.0
                    let percentage = 1.0 - (TimeInterval.sinceNow(to: finishTime) / totalSecond)
                    percentageBar(percentage)
                } else {
                    Text(
                        expedition.isFinished
                            ? "pzWidgetsKit.expedition.status.finished"
                            : "pzWidgetsKit.expedition.status.pending"
                    )
                    .lineLimit(1)
                    .font(.caption2)
                    .minimumScaleFactor(0.4)
                    .legibilityShadow()
                    percentageBar(expedition.isFinished ? 1 : 0.5)
                }
            }
        }
        .foregroundColor(Color("textColor3", bundle: .main))
    }

    @ViewBuilder
    func webView(url: URL, copilotURL: URL?) -> some View {
        let outerSize: CGFloat = 50
        GeometryReader { g in
            switch expedition.game {
            case .genshinImpact:
                NetworkImage(url: expedition.iconURL)
                    .scaleEffect(1.5)
                    .scaledToFit()
                    .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            case .starRail:
                let leaderAvatar = NetworkImage(url: expedition.iconURL)
                    .scaledToFit()
                    .background(.ultraThinMaterial, in: .circle)
                if let copilotURL {
                    ZStack {
                        leaderAvatar
                            .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                            .frame(maxWidth: outerSize, maxHeight: outerSize, alignment: .topLeading)
                        NetworkImage(url: copilotURL)
                            .scaledToFit()
                            .background(.thinMaterial, in: .circle)
                            .frame(maxWidth: outerSize / 2, maxHeight: outerSize / 2)
                            .frame(maxWidth: outerSize, maxHeight: outerSize, alignment: .bottomTrailing)
                    }
                    .frame(maxWidth: outerSize, maxHeight: outerSize)
                } else {
                    leaderAvatar
                }
            default: EmptyView()
            }
        }
        .frame(maxWidth: outerSize, maxHeight: outerSize)
        .environment(\.colorScheme, .light)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(width: g.size.width, height: g.size.height)
                .foregroundStyle(.regularMaterial)
                .brightness(-0.3)
                .environment(\.colorScheme, .light)
                .opacity(0.6)
                .environment(\.colorScheme, .light)
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(
                    width: g.size.width * percentage,
                    height: g.size.height
                )
                .foregroundStyle(.white)
            }
            .aspectRatio(30 / 1, contentMode: .fit)
            .compositingGroup()
        }
        .frame(height: 7)
    }
}
