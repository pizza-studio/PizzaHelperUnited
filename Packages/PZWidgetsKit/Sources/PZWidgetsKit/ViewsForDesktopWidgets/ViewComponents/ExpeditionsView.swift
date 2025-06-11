// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - DesktopWidgets.ExpeditionsView

@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct ExpeditionsView: View {
        // MARK: Lifecycle

        public init(
            layout: Layout = .normal,
            max4AllowedToDisplay: Bool = false,
            expeditions: [any ExpeditionTask],
            pilotAssetMap: [URL: SendableImagePtr]?
        ) {
            self.layout = layout
            self.max4AllowedToDisplay = max4AllowedToDisplay
            self.expeditions = expeditions
            self.pilotAssetMap = pilotAssetMap
        }

        // MARK: Public

        public enum Layout: String {
            case normal
            case tiny
            case tinyWithShrinkedIconSpaces
        }

        public var body: some View {
            ViewThatFits {
                VStack {
                    Group {
                        ForEach(expeditions, id: \.iconURL) { expedition in
                            EachExpeditionView(
                                layout: layout,
                                expedition: expedition,
                                pilotImage: getPilotImage(expedition.iconURL),
                                copilotImage: getPilotImage(expedition.iconURL4Copilot)
                            )
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: layout != .normal)
                VStack {
                    Group {
                        ForEach(filteredExpeditions, id: \.iconURL) { expedition in
                            EachExpeditionView(
                                layout: layout,
                                expedition: expedition,
                                pilotImage: getPilotImage(expedition.iconURL),
                                copilotImage: getPilotImage(expedition.iconURL4Copilot)
                            )
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: layout != .normal)
            }
        }

        // MARK: Private

        private struct EachExpeditionView: View {
            // MARK: Lifecycle

            public init(
                layout: Layout = .normal,
                expedition: any ExpeditionTask,
                pilotImage: Image?,
                copilotImage: Image?
            ) {
                self.layout = layout
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
                            let totalSecond = 20.0 * 60.0 * 60.0
                            let percentage = 1.0 - (TimeInterval.sinceNow(to: finishTime) / totalSecond)
                            percentageBar(percentage)
                            Text(PZWidgetsSPM.intervalFormatter.string(from: TimeInterval.sinceNow(to: finishTime))!)
                                .lineLimit(1)
                                .font(.caption2)
                                .minimumScaleFactor(0.4)
                                .legibilityShadow()
                        } else {
                            percentageBar(expedition.isFinished ? 1 : 0.5)
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
                        }
                    }
                    .fontWidth(.condensed)
                }
                .environment(\.colorScheme, .dark)
            }

            // MARK: Private

            private let layout: Layout
            private let expedition: any ExpeditionTask
            private let pilotImage: Image?
            private let copilotImage: Image?

            @ViewBuilder
            private func pilotsView() -> some View {
                let outerSize: CGFloat = 50
                let shouldShrinkIconPaneWidth: Bool = layout == .tinyWithShrinkedIconSpaces && expedition
                    .game != .starRail
                Group {
                    let leaderAvatarAsset: some View = Group {
                        if let pilotImage {
                            pilotImage
                                .resizable()
                        } else {
                            Image("NetworkImagePlaceholder", bundle: .module)
                                .resizable()
                        }
                    }
                    let leaderAvatar = leaderAvatarAsset
                        .scaledToFit()
                        .background(.ultraThinMaterial, in: .circle)
                    if let copilotImage {
                        switch layout {
                        case .normal:
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
                        case .tiny, .tinyWithShrinkedIconSpaces:
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
                        }
                    } else {
                        switch layout {
                        case .normal:
                            leaderAvatar
                                .frame(maxWidth: outerSize, maxHeight: outerSize)
                        case .tiny:
                            ZStack(alignment: .trailing) {
                                leaderAvatar
                                    .clipShape(.circle)
                                    .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                                    .frame(width: outerSize, alignment: .trailing)
                            }
                            .frame(maxWidth: outerSize, maxHeight: outerSize)
                        case .tinyWithShrinkedIconSpaces:
                            ZStack(alignment: .leading) {
                                leaderAvatar
                                    .clipShape(.circle)
                                    .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                                    .frame(width: outerSize, alignment: .center)
                            }
                            .frame(maxWidth: outerSize * 0.7, maxHeight: outerSize * 0.7)
                        }
                    }
                }
                .frame(maxWidth: outerSize, maxHeight: outerSize)
                .frame(width: shouldShrinkIconPaneWidth ? outerSize * 0.7 : outerSize)
                .fixedSize(horizontal: layout == .tinyWithShrinkedIconSpaces, vertical: false)
                .environment(\.colorScheme, .light)
            }

            @ViewBuilder
            private func percentageBar(_ percentage: Double) -> some View {
                let cornerRadius: CGFloat = 3
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Color.secondary.opacity(0.8)
                            .frame(width: g.size.width, height: g.size.height)
                            .brightness(-0.3)
                        Color.primary.opacity(0.625)
                            .frame(width: g.size.width * percentage, height: g.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .circular))
                    }
                    .aspectRatio(30 / 1, contentMode: .fit)
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .circular))
                    .environment(\.colorScheme, .dark)
                    .legibilityShadow(isText: false)
                }
                .frame(height: 7)
            }
        }

        private let layout: Layout
        private let max4AllowedToDisplay: Bool
        private let expeditions: [any ExpeditionTask]
        private let pilotAssetMap: [URL: SendableImagePtr]?

        private var filteredExpeditions: [any ExpeditionTask] {
            switch max4AllowedToDisplay {
            case false: return expeditions
            case true:
                let filtered = expeditions.sorted { lhs, rhs in
                    (lhs.timeOnFinish ?? Date()) > (rhs.timeOnFinish ?? Date())
                }.prefix(4)
                return Array(filtered)
            }
        }

        private func getPilotImage(_ url: URL?) -> Image? {
            guard let url else { return nil }
            return pilotAssetMap?[url]?.img
        }
    }
}

#if DEBUG && !os(watchOS)

@MainActor
private func prepareExpeditionsView4Preview(
    _ game: Pizza.SupportedGame,
    layout: DesktopWidgets.ExpeditionsView.Layout = .normal,
    max4AllowedToDisplay: Bool = false
)
    -> DesktopWidgets.ExpeditionsView {
    let dailyNote = game.exampleDailyNoteData
    let assetMap = dailyNote.getExpeditionAssetMapFromMainActor()
    return .init(
        layout: layout,
        max4AllowedToDisplay: max4AllowedToDisplay,
        expeditions: dailyNote.expeditionTasks,
        pilotAssetMap: assetMap
    )
}

#Preview {
    Group {
        Section {
            prepareExpeditionsView4Preview(
                .genshinImpact,
                layout: .tinyWithShrinkedIconSpaces,
                max4AllowedToDisplay: true
            )
        }
        Section {
            prepareExpeditionsView4Preview(.starRail, layout: .tinyWithShrinkedIconSpaces)
        }
    }
}

#endif
