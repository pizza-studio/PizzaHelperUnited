// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GachaProfileView.GachaStatsSection

extension GachaProfileView {
    public struct GachaStatsSection: View {
        // MARK: Lifecycle

        public init?(gpid: GachaProfileID?, poolType: GachaPoolExpressible?) {
            guard let gpid, let poolType else { return nil }
            self.givenGPID = gpid
            self.poolType = poolType
        }

        // MARK: Public

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
                            Text("gachaKit.stats.avaragePulls4LimitedPentaStars", bundle: .module)
                                .fontWidth(.condensed)
                        } icon: {
                            Image(systemSymbol: .starFill).foregroundStyle(.indigo)
                        }
                        Spacer()
                        Text(limitedDrawCount.description)
                            .fontWidth(.condensed)
                    }
                    HStack {
                        Label {
                            Text("gachaKit.stats.standardItemHitRate", bundle: .module)
                                .fontWidth(.condensed)
                        } icon: {
                            Image(systemSymbol: .trashCircleFill).foregroundStyle(.red)
                        }
                        Spacer()
                        Text(Self.fmtPerc.string(from: standardItemHitRate as NSNumber) ?? "N/A")
                            .fontWidth(.condensed)
                    }
                    guestEvaluatorView()
                }
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

        private var limitedDrawCount: Int {
            pentaStarEntries.map(\.drawCount).reduce(0, +) / max(pentaStarsNotSurinuked.count, 1)
        }

        // 如果获得的第一个五星是限定，默认其不歪
        private var surinukeEvasionRate: Double {
            // 歪次数 = 非限定五星数量
            let countSurinuked = Double(pentaStarEntries.count - pentaStarsNotSurinuked.count)
            // 小保底次数 = 限定五星数量
            var countEnsured = Double(pentaStarsNotSurinuked.count)
            // 如果抽的第一个是非限定，则多一次小保底
            if pentaStarEntries.last?.isSurinuked ?? false {
                countEnsured += 1
            }
            return 1.0 - countSurinuked / countEnsured
        }

        private var standardItemHitRate: Double {
            1.0 - surinukeEvasionRate
        }

        private var average5StarDraw: Int { pentaStarEntries.map { $0.drawCount }
            .reduce(0) { $0 + $1 } /
            max(pentaStarEntries.count, 1)
        }

        private var drawCountableAmount: Int {
            entries.firstIndex(where: { $0.rarity == .rank5 }) ?? entries.count
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
                    let judgedRank = ApprisedLevel.judge(limitedDrawNumber: limitedDrawCount, poolType: poolType)
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
    }
}

// MARK: - GachaProfileView.GachaStatsSection.ApprisedLevel

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
