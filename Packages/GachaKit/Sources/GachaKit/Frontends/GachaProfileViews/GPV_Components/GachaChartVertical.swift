// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - GachaChartVertical

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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
            LazyVStack(spacing: 0) {
                drawEntry(nil, avrgCount: avrgCount).id(-114514)
                ForEach(pentaStars) { thisEntry in
                    drawEntry(thisEntry, avrgCount: avrgCount)
                }
                drawEntry(nil, avrgCount: avrgCount, showRulerValues: true).id(-889464)
            }
        } else {
            Text("gachaKit.chart.noPentaStarsFound", bundle: .module)
                .foregroundColor(.secondary)
        }
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM

    private let poolType: GachaPoolExpressible
    private let givenGPID: GachaProfileID

    private var pentaStarEntries: [GachaEntryExpressible] {
        theVM.currentPentaStars
    }

    private var surinukedIcon: Image {
        GachaProfileView.GachaStatsSection.ApprisedLevel.one.appraiserIcon(game: givenGPID.game)
    }

    private var chartFont: Font {
        .system(size: 12).monospacedDigit()
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaChartVertical {
    @ViewBuilder
    private func drawEntry(
        _ entry: GachaEntryExpressible?,
        avrgCount: Int,
        showRulerValues: Bool = false
    )
        -> some View {
        let avrgCountLabelText = Text(
            verbatim: "gachaKit.chart.average".i18nGachaKit + ": \(avrgCount.description)"
        )
        HStack {
            // 肖像。
            Rectangle().fill(.clear).frame(width: 48, height: entry == nil ? 18 : 60)
                .overlay(alignment: .leading) {
                    if let entry {
                        entry.icon(48)
                    }
                }
            // 进度条部分
            GeometryReader { proxy in
                let containerWidth = proxy.size.width
                let containerHeight = proxy.size.height
                drawPercentageBackground(showRulerValues: showRulerValues)
                    .frame(maxHeight: .infinity)
                    .opacity(entry == nil && !showRulerValues ? 0 : 1)
                    // 平均线
                    .background(alignment: .leading) {
                        let widthRatio = Double(avrgCount) / 100
                        Rectangle().fill(.clear)
                            .frame(width: containerWidth * widthRatio, height: containerHeight)
                            .overlay(alignment: .trailing) {
                                if entry == nil, !showRulerValues {
                                    avrgCountLabelText
                                        .font(chartFont)
                                        .fixedSize()
                                        .foregroundColor(.gray)
                                        .offset(x: 20)
                                } else {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(entry == nil ? 0 : 0.5))
                                        .frame(width: 1)
                                }
                            }
                    }
                    // 资料条
                    .overlay(alignment: .leading) {
                        if let entry {
                            let widthRatio = min(1, Double(entry.drawCount) / 100)
                            HStack(spacing: 4) {
                                VStack(alignment: .leading, spacing: 4) {
                                    entry.nameView
                                        .fixedSize()
                                        .font(chartFont)
                                        .foregroundColor(.gray)
                                    HStack {
                                        Rectangle().fill(getColor(for: entry.drawCount))
                                            .frame(width: containerWidth * widthRatio, height: 20)
                                        Text(entry.drawCount.description)
                                            .font(chartFont)
                                            .foregroundColor(.gray)
                                            .fixedSize()
                                        Rectangle().fill(.clear)
                                            .frame(width: 35, height: 20)
                                    }
                                    .background(alignment: .trailing) {
                                        if poolType.isSurinukable, entry.isSurinuked {
                                            surinukedIcon
                                                .resizable().scaledToFit()
                                                .frame(width: 35, height: 35)
                                        }
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 尾端留白，留着画「歪」。
            Color.clear.frame(width: 30)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func drawPercentageBackground(showRulerValues: Bool = false) -> some View {
        HStack(spacing: 0) {
            Rectangle().fill(.clear)
                .overlay(alignment: .leading) {
                    Rectangle().fill(.clear).frame(width: 30)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(width: 1)
                        }
                        .background(alignment: .leading) {
                            if showRulerValues {
                                Text(verbatim: "0").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.clear).frame(width: 30)
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(width: 1)
                        }
                        .background(alignment: .trailing) {
                            if showRulerValues {
                                Text(verbatim: "25").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.clear).frame(width: 30)
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(width: 1)
                        }
                        .background(alignment: .trailing) {
                            if showRulerValues {
                                Text(verbatim: "50").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.clear).frame(width: 30)
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(width: 1)
                        }
                        .background(alignment: .trailing) {
                            if showRulerValues {
                                Text(verbatim: "75").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
            Rectangle().fill(.clear)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.clear).frame(width: 30)
                        .overlay(alignment: .trailing) {
                            Rectangle()
                                .fill(Color.secondary.opacity(showRulerValues ? 0 : 0.1))
                                .frame(width: 1)
                        }
                        .background(alignment: .trailing) {
                            if showRulerValues {
                                Text(verbatim: "100").font(chartFont).foregroundColor(.gray)
                            }
                        }
                }
        }
    }
}
