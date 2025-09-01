// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - GachaProfileView.GachaStatsSection

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaProfileView {
    public struct GachaStatsSection: View {
        // MARK: Lifecycle

        public init?(gpid: GachaProfileID?, poolType: GachaPoolExpressible?) {
            guard let gpid, let poolType else { return nil }
            self.givenGPID = gpid
            self.poolType = poolType
        }

        // MARK: Public

        /// Confidence level for the standard item hit rate calculation
        public enum StandardHitRateConfidence: CaseIterable {
            case high // >= 10 relevant cases
            case medium // 5-9 relevant cases
            case low // 3-4 relevant cases
            case insufficient // < 3 relevant cases

            // MARK: Lifecycle

            public init(casesAmount: Int) {
                self = switch casesAmount {
                case 10...: .high
                case 5 ..< 10: .medium
                case 3 ..< 5: .low
                default: .insufficient
                }
            }

            // MARK: Internal

            var i18nKeyStr: LocalizedStringKey {
                switch self {
                case .high: return "gachaKit.stats.confidence.high"
                case .medium: return "gachaKit.stats.confidence.medium"
                case .low: return "gachaKit.stats.confidence.low"
                case .insufficient: return "gachaKit.stats.confidence.insufficient"
                }
            }

            var localizedSUIText: Text {
                Text(i18nKeyStr, bundle: .module)
            }
        }

        public var body: some View {
            Section {
                HStack {
                    Label {
                        Text("gachaKit.stats.sincePreviousPentaStar", bundle: .module)
                            .fontWidth(.condensed)
                    } icon: {
                        Image(systemSymbol: .flagFill).foregroundStyle(.orange)
                    }
                    Spacer()
                    Text(
                        String(
                            format: "gachaKit.stats.pull:%lld".i18nGachaKit,
                            drawCountableAmount
                        )
                    )
                    .fontWidth(.condensed)
                }
                HStack {
                    Label {
                        Text("gachaKit.stats.totalPulls", bundle: .module)
                            .fontWidth(.condensed)
                    } icon: {
                        Image(systemSymbol: .handTapFill).foregroundStyle(.brown)
                    }
                    Spacer()
                    Text(entries.count.description)
                        .fontWidth(.condensed)
                }
                HStack {
                    Label {
                        Text("gachaKit.stats.avaragePulls4PentaStars", bundle: .module)
                            .fontWidth(.condensed)
                    } icon: {
                        Image(systemSymbol: .star).foregroundStyle(.green)
                    }
                    Spacer()
                    Text(average5StarDraw.description)
                        .fontWidth(.condensed)
                }
                if poolType.isSurinukable, theVM.taskState != .busy {
                    HStack {
                        Label {
                            Text("gachaKit.stats.avaragePulls4NonStandardPentaStars", bundle: .module)
                                .fontWidth(.condensed)
                        } icon: {
                            Image(systemSymbol: .starFill).foregroundStyle(.indigo)
                        }
                        Spacer()
                        Text(average5StarDrawLimited.description)
                            .fontWidth(.condensed)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Label {
                                Text("gachaKit.stats.standardItemHitRate", bundle: .module)
                                    .fontWidth(.condensed)
                            } icon: {
                                Image(systemSymbol: .trashCircleFill).foregroundStyle(.red)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(Self.fmtPerc.string(from: standardItemHitRate as NSNumber) ?? "N/A")
                                    .fontWidth(.condensed)
                                // Show confidence indicator for medium/low/insufficient confidence
                                drawStandardHitRateConfidenceWarningButton()
                            }
                        }
                    }
                    guestEvaluatorView()
                }
            }
            .alert(
                Text("gachaKit.stats.confidence.alert.title", bundle: .module),
                isPresented: $isConfidenceExplanationAlertShown
            ) {
                Button("sys.ok".i18nBaseKit) {
                    isConfidenceExplanationAlertShown = false
                }
            } message: {
                Text("gachaKit.stats.confidence.alert.message", bundle: .module)
            }
        }

        // MARK: Private

        private static let fmtPerc: NumberFormatter = {
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 2
            fmt.numberStyle = .percent
            return fmt
        }()

        @Environment(GachaVM.self) private var theVM
        @State private var isConfidenceExplanationAlertShown: Bool = false

        private let poolType: GachaPoolExpressible
        private let givenGPID: GachaProfileID

        private var entries: [GachaEntryExpressible] {
            theVM.mappedEntriesByPools[poolType] ?? []
        }

        private var pentaStarEntries: [GachaEntryExpressible] {
            theVM.currentPentaStars
        }

        private var pentaStarsNotSurinuked: [GachaEntryExpressible] {
            theVM.currentPentaStars.filter { entry in
                !entry.isSurinuked
            }
        }

        private var average5StarDrawLimited: Int {
            pentaStarEntries.map(\.drawCount).reduce(0, +) / max(pentaStarsNotSurinuked.count, 1)
        }

        /// Confidence level of the standard item hit rate calculation
        private var standardItemHitRateConfidence: StandardHitRateConfidence {
            var result = StandardHitRateConfidence(casesAmount: pentaStarEntries.count)
            // Cap the confidence to `medium` if the rate runs out of theoretical bounds (0-50%).
            if result == .high, standardItemHitRate > 0.515 {
                result = .medium
            }
            return result
        }

        /// Get the relevant cases for standard item hit rate calculation
        private var standardItemHitRateCalculationCases: [Bool] {
            let pentaStarEntries = pentaStarEntries
            guard !pentaStarEntries.isEmpty else { return [] }

            var surinukableCases = [Bool]()
            var previousPentaStarIsSurinuked = false

            for theEntry in pentaStarEntries.reversed() {
                let isCurrentItemSurinuked = theEntry.isSurinuked
                defer {
                    previousPentaStarIsSurinuked = isCurrentItemSurinuked
                }
                switch theEntry.isSurinuked {
                case true:
                    surinukableCases.append(true)
                case false:
                    guard !previousPentaStarIsSurinuked else { continue }
                    surinukableCases.append(false)
                }
            }
            return surinukableCases
        }

        private var standardItemHitRate: Double {
            let surinukableCases = standardItemHitRateCalculationCases
            guard surinukableCases.count >= 3 else { return 0.0 } // Insufficient data
            let countSurinuked = Double(surinukableCases.count(where: \.self))
            let rate = countSurinuked / Double(surinukableCases.count)
            return rate
        }

        private var average5StarDraw: Int {
            pentaStarEntries.map {
                $0.drawCount
            }.reduce(0) {
                $0 + $1
            } / max(pentaStarEntries.count, 1)
        }

        private var drawCountableAmount: Int {
            entries.firstIndex(where: { $0.rarity == .rank5 }) ?? entries.count
        }

        /// Icon to display for confidence level
        private var confidenceIcon: SFSymbol {
            switch standardItemHitRateConfidence {
            case .high: return .checkmarkCircleFill
            case .medium: return .exclamationmarkTriangleFill
            case .low: return .questionmarkCircleFill
            case .insufficient: return .xmarkCircleFill
            }
        }

        /// Color for confidence indicator
        private var confidenceColor: Color {
            switch standardItemHitRateConfidence {
            case .high: return .green
            case .medium: return .orange
            case .low: return .yellow
            case .insufficient: return .red
            }
        }

        @ViewBuilder
        private func guestEvaluatorView() -> some View {
            VStack {
                HStack {
                    Text(LocalizedStringKey(stringLiteral: poolType.appraiserDescriptionKey), bundle: .module)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack {
                    Spacer()
                    let judgedRank = ApprisedLevel.judge(limitedDrawNumber: average5StarDrawLimited, poolType: poolType)
                    ForEach(ApprisedLevel.allCases, id: \.rawValue) { rankLevel in
                        Group {
                            rankLevel.appraiserIcon(game: givenGPID.game)
                                .resizable()
                                .scaledToFit()
                                .opacity(judgedRank == rankLevel ? 1 : 0.25)
                        }
                        .frame(width: 50, height: 50)
                        Spacer()
                    }
                }
            }
        }

        @ViewBuilder
        private func drawStandardHitRateConfidenceWarningButton() -> some View {
            if standardItemHitRateConfidence != .high {
                Button {
                    isConfidenceExplanationAlertShown = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemSymbol: confidenceIcon)
                            .foregroundStyle(confidenceColor)
                            .font(.caption2)
                        standardItemHitRateConfidence.localizedSUIText
                            .font(.caption2)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

// MARK: - GachaProfileView.GachaStatsSection.ApprisedLevel

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaProfileView.GachaStatsSection {
    // MARK: Internal

    /// 抽卡评分，数字值越小则评价越低。
    public enum ApprisedLevel: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5

        // MARK: Internal

        func appraiserIcon(game: Pizza.SupportedGame) -> Image {
            let header: String = game.rawValue.lowercased()
            let fileName = "\(header)_appraiserIcon_\(rawValue)"
            return Image(fileName, bundle: .module)
        }

        // MARK: Fileprivate

        // swiftlint:disable:next cyclomatic_complexity
        fileprivate static func judge(
            limitedDrawNumber: Int,
            poolType: GachaPoolExpressible
        )
            -> Self {
            guard poolType.isSurinukable else { return .one }
            return switch limitedDrawNumber {
            case ...80: .five
            case 80 ..< 90: .four
            case 90 ..< 100: .three
            case 100 ..< 110: .two
            case 110...: .one
            default: .one
            }
        }
    }
}
