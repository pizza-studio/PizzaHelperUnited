// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Charts
import PZBaseKit
import SwiftUI

// MARK: - GachaChartVertical

public struct GachaChartVertical: View {
    // MARK: Lifecycle

    public init?(gpid: GachaProfileID?, poolType: GachaPoolExpressible?) {
        guard let gpid, let poolType else { return nil }
        self.givenGPID = gpid
        self.poolType = poolType
    }

    // MARK: Public

    @MainActor public var body: some View {
        let frozenEntries: [EntryPair] = entries
        let entriesOf5Star = extract5Stars(frozenEntries)
        if !entriesOf5Star.isEmpty {
            VStack(spacing: -12) {
                ForEach(entriesOf5Star.chunked(into: 60), id: \.first!.0.id) { chunkedEntries in
                    let chunkedEntriesOf5Star = extract5Stars(chunkedEntries)
                    let isFirst = Bool(equalCheck: entriesOf5Star.first?.0.id, against: chunkedEntries.first?.0.id)
                    let isLast = Bool(equalCheck: entriesOf5Star.last?.0.id, against: chunkedEntries.last?.0.id)
                    subChart(
                        givenEntries: chunkedEntries,
                        fiveStarEntries: chunkedEntriesOf5Star,
                        isFirst: isFirst,
                        isLast: isLast
                    ).padding(isFirst ? .top : [])
                }
            }
        } else {
            Text("gachaKit.chart.noPentaStarsFound".i18nGachaKit)
                .foregroundColor(.secondary)
        }
    }

    // MARK: Fileprivate

    fileprivate typealias EntryPair = (entry: GachaEntryExpressible, drawCount: Int)

    fileprivate let poolType: GachaPoolExpressible
    fileprivate let givenGPID: GachaProfileID
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var entries: [EntryPair] {
        let preFiltered = theVM.cachedEntries.filter { $0.pool == poolType }
        let drawCounts = preFiltered.drawCounts
        return Array(zip(preFiltered, drawCounts))
    }

    fileprivate var surinukedIcon: Image {
        GachaProfileView.GachaStatsSection.ApprisedLevel.one.appraiserIcon(game: givenGPID.game)
    }

    fileprivate func extract5Stars(_ source: [EntryPair]) -> [EntryPair] {
        source.filter { $0.0.rarity == .rank5 }
    }

    @MainActor @ViewBuilder
    fileprivate func subChart(
        givenEntries: [EntryPair],
        fiveStarEntries: [EntryPair],
        isFirst: Bool,
        isLast: Bool
    )
        -> some View {
        let averagePullsCount: Int = fiveStarEntries.map(\.drawCount).reduce(0, +) / max(fiveStarEntries.count, 1)
        Chart {
            ForEach(givenEntries, id: \.0.id) { entry in
                drawChartContent(for: entry)
            }
            if !fiveStarEntries.isEmpty {
                RuleMark(x: .value("gachaKit.chart.average".i18nGachaKit, averagePullsCount))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .annotation(alignment: .topLeading) {
                        if isFirst {
                            Text("gachaKit.chart.average".i18nGachaKit + averagePullsCount.description)
                                .font(.caption).foregroundColor(.gray)
                        }
                    }
            }
        }
        .chartYAxis {
            axisContentY(entries: givenEntries)
        }
        .chartXAxis {
            axisContentX(isLast: isLast)
        }
        .chartXScale(domain: 0 ... 110)
        .frame(height: CGFloat(givenEntries.count * 65))
        .chartForegroundStyleScale(range: colors(entries: fiveStarEntries))
        .chartLegend(.hidden)
    }

    fileprivate func matchedEntries(
        among source: [EntryPair],
        with value: String
    )
        -> [GachaEntryExpressible] {
        source.map(\.0).filter { $0.id == value }
    }

    fileprivate func colors(entries: [EntryPair]) -> [Color] {
        entries.map { _, count in
            switch count {
            case 0 ..< 62:
                return .green
            case 62 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }

    @ChartContentBuilder
    fileprivate func drawChartContent(for entry: EntryPair) -> some ChartContent {
        BarMark(
            x: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.drawCount),
            y: .value("gachaKit.chart.character".i18nGachaKit, entry.0.id),
            height: .fixed(20)
        )
        .annotation(position: .trailing) {
            HStack(spacing: 3) {
                let frame: CGFloat = 35
                Text("\(entry.drawCount)").foregroundColor(.gray).font(.caption)
                if poolType.isSurinukable, entry.0.isSurinuked {
                    surinukedIcon.resizable().scaledToFit()
                        .frame(width: frame, height: frame)
                        .offset(y: -5)
                } else {
                    EmptyView()
                }
            }
        }
        .foregroundStyle(by: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.0.id))
    }

    @AxisContentBuilder
    fileprivate func axisContentY(entries givenEntries: [EntryPair]) -> some AxisContent {
        AxisMarks(preset: .aligned, position: .leading) { value in
            AxisValueLabel(content: {
                if let id = value.as(String.self),
                   let entry = matchedEntries(among: givenEntries, with: id).first {
                    entry.icon(45)
                } else {
                    EmptyView()
                }
            })
        }
        AxisMarks { value in
            AxisValueLabel(content: {
                if let theValue = value.as(String.self),
                   let entry = matchedEntries(among: givenEntries, with: theValue).first {
                    entry.nameView
                        .padding(.bottom, 4)
                        .offset(y: givenEntries.count == 1 ? 0 : 8)
                } else {
                    EmptyView()
                }
            })
        }
    }

    @AxisContentBuilder
    fileprivate func axisContentX(isLast: Bool) -> some AxisContent {
        AxisMarks(values: [0, 25, 50, 75, 100]) { _ in
            AxisGridLine()
            if isLast {
                AxisValueLabel()
            } else {
                AxisValueLabel {
                    EmptyView()
                }
            }
        }
    }
}
