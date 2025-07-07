// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - GachaChartHorizontal

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaChartHorizontal: View {
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
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    // 这里必须用 LazyVStack，否则真的要卡到死。
                    LazyHStack(spacing: 0) {
                        drawEntry(nil, avrgCount: avrgCount).id(-114514)
                            .offset(y: -6)
                        ForEach(pentaStars) { thisEntry in
                            drawEntry(thisEntry, avrgCount: avrgCount)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(height: 120)
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
        } else {
            Text("gachaKit.chart.noPentaStarsFound", bundle: .module)
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM

    private let poolType: GachaPoolExpressible
    private let givenGPID: GachaProfileID

    private var pentaStarEntries: [GachaEntryExpressible] {
        theVM.currentPentaStars
    }

    private var chartFont: Font {
        .system(size: 11).monospacedDigit()
    }

    private func getColor(for drawCount: Int) -> Color {
        switch drawCount {
        case ..<0: .gray
        case 0 ..< 50: .cyan
        case 50 ..< 62: .green
        case 62 ..< 70: .yellow
        case 70 ..< 80: .orange
        default: .red
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaChartHorizontal {
    @ViewBuilder
    private func drawEntry(
        _ entry: GachaEntryExpressible?,
        avrgCount: Int
    )
        -> some View {
        VStack(spacing: 3) {
            Color.clear.frame(height: 10)
            // 进度条部分
            GeometryReader { proxy in
                let containerWidth = proxy.size.width
                let containerHeight = proxy.size.height
                drawPercentageBackground(showRulerValues: entry == nil)
                    .frame(maxWidth: .infinity)
                    // 平均线
                    .overlay(alignment: .top) {
                        if entry != nil {
                            let heightRatio = (100.0 - Double(avrgCount)) / 100
                            Rectangle().fill(.clear)
                                .frame(width: containerWidth, height: containerHeight * heightRatio)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.5))
                                        .frame(height: 1)
                                }
                        }
                    }
                    // 资料条
                    .overlay(alignment: .bottom) {
                        if let entry {
                            let heightRatio = min(1, Double(entry.drawCount) / 100)
                            VStack(spacing: 2) {
                                Text(entry.drawCount.description)
                                    .font(chartFont)
                                    .foregroundColor(.gray)
                                Rectangle().fill(getColor(for: entry.drawCount))
                                    .frame(width: 25, height: containerHeight * heightRatio)
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 肖像。
            Rectangle().fill(.clear).frame(width: entry == nil ? 30 : 49, height: 30)
                .overlay(alignment: .bottom) {
                    if let entry {
                        entry.icon(30)
                    }
                }
                .background(alignment: .topTrailing) {
                    if entry == nil {
                        Text(verbatim: "0")
                            .font(chartFont)
                            .foregroundColor(.gray)
                            .offset(x: -2, y: -6)
                    }
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private func drawPercentageBackground(showRulerValues: Bool = false) -> some View {
        VStack(spacing: 0) {
            Rectangle().fill(.clear)
                .overlay(alignment: .top) {
                    Rectangle().fill(.clear).frame(height: 15)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(height: 1)
                        }
                        .background(alignment: .topTrailing) {
                            if showRulerValues {
                                Text(verbatim: "100").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .top) {
                    Rectangle().fill(.clear).frame(height: 15)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(height: 1)
                        }
                        .background(alignment: .topTrailing) {
                            if showRulerValues {
                                Text(verbatim: "75").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .top) {
                    Rectangle().fill(.clear).frame(height: 15)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(height: 1)
                        }
                        .background(alignment: .topTrailing) {
                            if showRulerValues {
                                Text(verbatim: "50").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(.clear).frame(height: 15)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(height: 1)
                        }
                }
                .overlay(alignment: .top) {
                    Rectangle().fill(.clear).frame(height: 15)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(height: 1)
                        }
                        .background(alignment: .topTrailing) {
                            if showRulerValues {
                                Text(verbatim: "25").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
        }
        .padding(.trailing, showRulerValues ? 2 : 0)
    }
}
