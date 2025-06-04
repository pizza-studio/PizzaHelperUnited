// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ExpeditionsView

@available(watchOS, unavailable)
public struct ExpeditionsView: View {
    // MARK: Lifecycle

    public init(expeditions: [any ExpeditionTask], pilotAssetMap: [URL: SendableImagePtr]?) {
        self.expeditions = expeditions
        self.pilotAssetMap = pilotAssetMap
    }

    // MARK: Public

    public var body: some View {
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

    private let expeditions: [any ExpeditionTask]
    private let pilotAssetMap: [URL: SendableImagePtr]?

    private func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }
}

// MARK: - EachExpeditionView

@available(watchOS, unavailable)
private struct EachExpeditionView: View {
    // MARK: Lifecycle

    public init(expedition: any ExpeditionTask, pilotImage: Image?, copilotImage: Image?) {
        self.expedition = expedition
        self.pilotImage = pilotImage
        self.copilotImage = copilotImage
    }

    // MARK: Public

    public var body: some View {
        HStack {
            pilotsView()
            VStack(alignment: .leading) {
                if !expedition.isFinished, let finishTime = expedition.timeOnFinish {
                    Text(PZWidgetsSPM.intervalFormatter.string(from: TimeInterval.sinceNow(to: finishTime))!)
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
                            : "pzWidgetsKit.expedition.status.pending",
                        bundle: .module
                    )
                    .lineLimit(1)
                    .font(.caption2)
                    .minimumScaleFactor(0.4)
                    .legibilityShadow()
                    percentageBar(expedition.isFinished ? 1 : 0.5)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: Private

    private let expedition: any ExpeditionTask
    private let pilotImage: Image?
    private let copilotImage: Image?

    @ViewBuilder
    private func pilotsView() -> some View {
        let outerSize: CGFloat = 50
        GeometryReader { g in
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
                        .clipShape(.circle)
                        .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                        .frame(maxWidth: outerSize, maxHeight: outerSize, alignment: .topLeading)
                    copilotImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(.circle)
                        .background(.thinMaterial, in: .circle)
                        .frame(maxWidth: outerSize / 2, maxHeight: outerSize / 2)
                        .frame(maxWidth: outerSize, maxHeight: outerSize, alignment: .bottomTrailing)
                }
                .frame(maxWidth: outerSize, maxHeight: outerSize)
            } else {
                leaderAvatar
            }
        }
        .frame(maxWidth: outerSize, maxHeight: outerSize)
        .environment(\.colorScheme, .light)
    }

    @ViewBuilder
    private func percentageBar(_ percentage: Double) -> some View {
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
