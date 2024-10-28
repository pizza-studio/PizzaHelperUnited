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

    public var body: some View {
        let pentaStars = pentaStarEntries
        let avrgCount: Int = pentaStars.map(\.drawCount).reduce(0, +) / max(pentaStars.count, 1)
        if !pentaStars.isEmpty {
            // 这里必须用 LazyVStack，否则真的要卡到死。
            LazyVStack(spacing: -12) {
                ForEach(shouldChunk ? pentaStars.chunked(into: 5) : [pentaStars], id: \.first!.id) { chunk in
                    let isFirst = Bool(equalCheck: pentaStars.first?.id, against: chunk.first?.id)
                    let isLast = Bool(equalCheck: pentaStars.last?.id, against: chunk.last?.id)
                    subChart(
                        givenEntries: chunk,
                        averagePullsCount: avrgCount,
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

    fileprivate let poolType: GachaPoolExpressible
    fileprivate let givenGPID: GachaProfileID
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var shouldChunk: Bool {
        if #available(iOS 18, *) {
            return false
        }
        if #available(macOS 15, *) {
            return false
        }
        if #available(macCatalyst 18, *) {
            return false
        }
        return true
    }

    fileprivate var pentaStarEntries: [GachaEntryExpressible] {
        theVM.currentPentaStars
    }

    fileprivate var surinukedIcon: Image {
        GachaProfileView.GachaStatsSection.ApprisedLevel.one.appraiserIcon(game: givenGPID.game)
    }

    @ViewBuilder
    fileprivate func subChart(
        givenEntries: [GachaEntryExpressible],
        averagePullsCount: Int,
        isFirst: Bool,
        isLast: Bool
    )
        -> some View {
        Chart {
            ForEach(givenEntries) { entry in
                drawChartContent(for: entry)
            }
            if !givenEntries.isEmpty {
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
        .chartForegroundStyleScale(range: colors(entries: givenEntries))
        .chartLegend(.hidden)
    }

    fileprivate func matchedEntries(
        among source: [GachaEntryExpressible],
        with value: String
    )
        -> [GachaEntryExpressible] {
        source.filter { $0.id == value }
    }

    fileprivate func colors(entries: [GachaEntryExpressible]) -> [Color] {
        entries.map { neta in
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

    @ChartContentBuilder
    fileprivate func drawChartContent(for entry: GachaEntryExpressible) -> some ChartContent {
        BarMark(
            x: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.drawCount),
            y: .value("gachaKit.chart.character".i18nGachaKit, entry.id),
            height: .fixed(20)
        )
        .annotation(position: .trailing) {
            HStack(spacing: 3) {
                let frame: CGFloat = 35
                Text(entry.drawCount.description).foregroundColor(.gray).font(.caption)
                if poolType.isSurinukable, entry.isSurinuked {
                    surinukedIcon.resizable().scaledToFit()
                        .frame(width: frame, height: frame)
                        .offset(y: -5)
                } else {
                    EmptyView()
                }
            }
        }
        .foregroundStyle(by: .value("gachaKit.chart.pullCount".i18nGachaKit, entry.id))
    }

    @AxisContentBuilder
    fileprivate func axisContentY(entries givenEntries: [GachaEntryExpressible]) -> some AxisContent {
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
                        .environment(theVM)
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
