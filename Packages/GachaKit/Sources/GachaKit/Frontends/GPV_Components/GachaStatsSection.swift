// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftData
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

        @MainActor public var body: some View {
            Section {
                HStack {
                    Label(
                        "gachaKit.stats.sincePreviousPentaStar".i18nGachaKit,
                        systemSymbol: .flagFill
                    )
                    Spacer()
                    Text(
                        String(
                            format: "gachaKit.stats.pull:%lld".i18nGachaKit,
                            drawCountableAmount
                        )
                    )
                }
                HStack {
                    Label(
                        "gachaKit.stats.totalPulls".i18nGachaKit,
                        systemSymbol: .handTapFill
                    )
                    Spacer()
                    Text(entriesWithDrawCount.count.description)
                }
                HStack {
                    Label(
                        "gachaKit.stats.avaragePulls4PentaStars".i18nGachaKit,
                        systemSymbol: .star
                    )
                    Spacer()
                    Text(average5StarDraw.description)
                }
                if poolType.isSurinukable {
                    HStack {
                        Label(
                            "gachaKit.stats.avaragePulls4LimitedPentaStars".i18nGachaKit,
                            systemSymbol: .starFill
                        )
                        Spacer()
                        Text(limitedDrawCount.description)
                    }
                    HStack {
                        Label(
                            "gachaKit.stats.surinukeEvasionRate".i18nGachaKit,
                            systemSymbol: .chartPieFill
                        )
                        Spacer()
                        Text(Self.fmtPerc.string(from: surinukeEvasionRate as NSNumber) ?? "N/A")
                    }
                    guestEvaluatorView()
                }
            }
        }

        // MARK: Fileprivate

        fileprivate static let fmtPerc: NumberFormatter = {
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 2
            fmt.numberStyle = .percent
            return fmt
        }()

        @Environment(GachaVM.self) fileprivate var theVM

        fileprivate let poolType: GachaPoolExpressible
        fileprivate let givenGPID: GachaProfileID

        fileprivate var entries: [GachaEntryExpressible] {
            theVM.cachedEntries.filter { $0.pool == poolType }
        }

        fileprivate var entriesWithDrawCount: [(GachaEntryExpressible, drawCount: Int)] {
            Array(zip(entries, entries.drawCounts))
        }

        fileprivate var fiveStarEntriesWithDrawCount: [(GachaEntryExpressible, drawCount: Int)] {
            entriesWithDrawCount.filter { entry, _ in
                entry.rarity == .rank5
            }
        }

        fileprivate var fiveStarsNotSurinuked: [GachaEntryExpressible] {
            entries.filter { entry in
                entry.rarity == .rank5 && !entry.isSurinuked
            }
        }

        fileprivate var limitedDrawCount: Int {
            fiveStarEntriesWithDrawCount.map(\.drawCount).reduce(0, +) / max(fiveStarsNotSurinuked.count, 1)
        }

        // 如果获得的第一个五星是限定，默认其不歪
        fileprivate var surinukeEvasionRate: Double {
            // 歪次数 = 非限定五星数量
            let countSurinuked = Double(fiveStarEntriesWithDrawCount.count - fiveStarsNotSurinuked.count)
            // 小保底次数 = 限定五星数量
            var countEnsured = Double(fiveStarsNotSurinuked.count)
            // 如果抽的第一个是非限定，则多一次小保底
            if fiveStarEntriesWithDrawCount.last?.0.isSurinuked ?? false {
                countEnsured += 1
            }
            return 1.0 - countSurinuked / countEnsured
        }

        fileprivate var average5StarDraw: Int { fiveStarEntriesWithDrawCount.map { $0.drawCount }
            .reduce(0) { $0 + $1 } /
            max(fiveStarEntriesWithDrawCount.count, 1)
        }

        fileprivate var drawCountableAmount: Int {
            entriesWithDrawCount.firstIndex(where: { $0.0.rarity == .rank5 }) ?? entriesWithDrawCount.count
        }

        @MainActor @ViewBuilder
        fileprivate func guestEvaluatorView() -> some View {
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
