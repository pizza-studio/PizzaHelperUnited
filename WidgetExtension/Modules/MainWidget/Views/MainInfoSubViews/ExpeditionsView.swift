// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

// MARK: - ExpeditionsView

@available(watchOS, unavailable)
struct ExpeditionsView: View {
    // MARK: Internal

    let expeditions: [any ExpeditionTask]
    let pilotAssetMap: [URL: SendableImagePtr]?

    var body: some View {
        VStack {
            ForEach(expeditions, id: \.iconURL) { expedition in
                EachExpeditionView(
                    expedition: expedition,
                    pilotImage: getPilotImage(expedition.iconURL),
                    copilotImage: getPilotImage(expedition.iconURL4Copilot)
                )
            }
        }
    }

    // MARK: Private

    private func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }
}

// MARK: - EachExpeditionView

@available(watchOS, unavailable)
struct EachExpeditionView: View {
    let expedition: any ExpeditionTask
    let viewConfig: WidgetViewConfiguration = .defaultConfig
    let pilotImage: Image?
    let copilotImage: Image?

    var body: some View {
        HStack {
            pilotsView()
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
        .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
    }

    @ViewBuilder
    func pilotsView() -> some View {
        let outerSize: CGFloat = 50
        GeometryReader { g in
            switch expedition.game {
            case .genshinImpact:
                Group {
                    if let pilotImage {
                        pilotImage
                            .resizable()
                    } else {
                        Image("NetworkImagePlaceholder", bundle: .main)
                            .resizable()
                    }
                }
                .scaleEffect(1.5)
                .scaledToFit()
                .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
            case .starRail:
                let leaderAvatarAsset: some View = Group {
                    if let pilotImage {
                        pilotImage
                            .resizable()
                    } else {
                        Image("NetworkImagePlaceholder", bundle: .main)
                            .resizable()
                    }
                }
                let leaderAvatar = leaderAvatarAsset
                    .scaledToFit()
                    .background(.ultraThinMaterial, in: .circle)
                if let copilotImage {
                    ZStack {
                        leaderAvatar
                            .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                            .frame(maxWidth: outerSize, maxHeight: outerSize, alignment: .topLeading)
                        copilotImage
                            .resizable()
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
