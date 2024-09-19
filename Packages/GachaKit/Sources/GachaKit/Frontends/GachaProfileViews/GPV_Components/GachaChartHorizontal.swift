// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Charts
import PZBaseKit
import SwiftData
import SwiftUI

public struct GachaChartHorizontal: View {
    // MARK: Lifecycle

    public init?(gpid: GachaProfileID?, poolType: GachaPoolExpressible?) {
        guard let gpid, let poolType else { return nil }
        self.givenGPID = gpid
        self.poolType = poolType
    }

    // MARK: Public

    @MainActor public var body: some View {
        if fiveStarEntries.isEmpty {
            Text("gachaKit.chart.noDataRepresentableForNow".i18nGachaKit)
                .font(.caption)
        } else {
            VStack(alignment: .leading) {
                chart()
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
        }
    }

    // MARK: Fileprivate

    fileprivate typealias EntryPair = (entry: GachaEntryExpressible, drawCount: Int)

    fileprivate let poolType: GachaPoolExpressible
    fileprivate let givenGPID: GachaProfileID
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var fiveStarEntries: [EntryPair] {
        let theEntries = entries
        let drawCounts = theEntries.drawCounts
        return zip(theEntries, drawCounts)
            .filter { entry, _ in
                entry.rarity == .rank5
            }
    }

    fileprivate var colors: [Color] {
        fiveStarEntries.map { _, count in
            switch count {
            case 0 ..< 60:
                return .green
            case 60 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }

    fileprivate var entries: [GachaEntryExpressible] {
        theVM.cachedEntries.filter { $0.pool == poolType }
    }

    @MainActor @ViewBuilder
    fileprivate func chart() -> some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(fiveStarEntries, id: \.0.id) { entry in
                    drawChartContent(for: entry)
                }
                if !fiveStarEntries.isEmpty {
                    drawChartContentRuleMarks()
                }
            }
            .chartXAxis(content: {
                AxisMarks { value in
                    AxisValueLabel(content: {
                        Group {
                            if let id = value.as(String.self),
                               let entry = matchedEntry(from: fiveStarEntries, with: id) {
                                entry.icon(30)
                            } else {
                                EmptyView()
                            }
                        }
                        .fixedSize()
                    })
                }
            })
            .chartLegend(position: .top)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartYScale(domain: [0, 100])
            .chartForegroundStyleScale(range: colors)
            .chartLegend(.hidden)
            .frame(width: CGFloat(fiveStarEntries.count * 50))
            .padding(.top)
            .padding(.bottom, 5)
            .padding(.leading, 1)
        }
    }

    fileprivate func matchedEntry(
        from source: [EntryPair],
        with value: String
    )
        -> GachaEntryExpressible? {
        source.first(where: { $0.0.id == value })?.0
    }

    @ChartContentBuilder
    fileprivate func drawChartContent(for entry: EntryPair) -> some ChartContent {
        BarMark(
            x: .value("gachaKit.chart.character".i18nGachaKit, entry.0.id),
            y: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.drawCount),
            width: .fixed(25)
        )
        .annotation(position: .top) {
            Text("\(entry.drawCount)").foregroundColor(.gray)
                .font(.caption)
        }
        .foregroundStyle(by: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.0.id))
    }

    @ChartContentBuilder
    fileprivate func drawChartContentRuleMarks() -> some ChartContent {
        RuleMark(y: .value(
            "gachaKit.chart.average".i18nGachaKit,
            fiveStarEntries.map { $0.drawCount }
                .reduce(0) { $0 + $1 } / max(fiveStarEntries.count, 1)
        ))
        .foregroundStyle(.gray)
        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
    }
}
