// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Charts
import PZBaseKit
import SwiftUI

public struct GachaChartHorizontal: View {
    // MARK: Lifecycle

    public init?(gpid: GachaProfileID?, poolType: GachaPoolExpressible?) {
        guard let gpid, let poolType else { return nil }
        self.givenGPID = gpid
        self.poolType = poolType
    }

    // MARK: Public

    public var body: some View {
        if pentaStarEntries.isEmpty {
            Text("gachaKit.chart.noPentaStarsFound".i18nGachaKit)
                .font(.caption)
        } else {
            VStack(alignment: .leading) {
                chart()
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
        }
    }

    // MARK: Fileprivate

    fileprivate let poolType: GachaPoolExpressible
    fileprivate let givenGPID: GachaProfileID
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var pentaStarEntries: [GachaEntryExpressible] {
        theVM.currentPentaStars
    }

    fileprivate var colors: [Color] {
        pentaStarEntries.map { neta in
            switch neta.drawCount {
            case ..<0: .gray
            case 0 ..< 50: .cyan
            case 50 ..< 62: .green
            case 62 ..< 70: .yellow
            case 70 ..< 80: .orange
            default: .red
            }
        }
    }

    @ViewBuilder
    fileprivate func chart() -> some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(pentaStarEntries) { entry in
                    drawChartContent(for: entry)
                }
                if !pentaStarEntries.isEmpty {
                    drawChartContentRuleMarks()
                }
            }
            .chartXAxis(content: {
                AxisMarks { value in
                    AxisValueLabel(content: {
                        Group {
                            if let id = value.as(String.self),
                               let entry = matchedEntry(from: pentaStarEntries, with: id) {
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
            .frame(width: CGFloat(pentaStarEntries.count * 50))
            .padding(.top)
            .padding(.bottom, 5)
            .padding(.leading, 1)
        }
    }

    fileprivate func matchedEntry(
        from source: [GachaEntryExpressible],
        with value: String
    )
        -> GachaEntryExpressible? {
        source.first(where: { $0.id == value })
    }

    @ChartContentBuilder
    fileprivate func drawChartContent(for entry: GachaEntryExpressible) -> some ChartContent {
        BarMark(
            x: .value("gachaKit.chart.character".i18nGachaKit, entry.id),
            y: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.drawCount),
            width: .fixed(25)
        )
        .annotation(position: .top) {
            Text(entry.drawCount.description).foregroundColor(.gray)
                .font(.caption)
        }
        .foregroundStyle(by: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.id))
    }

    @ChartContentBuilder
    fileprivate func drawChartContentRuleMarks() -> some ChartContent {
        RuleMark(y: .value(
            "gachaKit.chart.average".i18nGachaKit,
            pentaStarEntries.map { $0.drawCount }
                .reduce(0) { $0 + $1 } / max(pentaStarEntries.count, 1)
        ))
        .foregroundStyle(.gray)
        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
    }
}
