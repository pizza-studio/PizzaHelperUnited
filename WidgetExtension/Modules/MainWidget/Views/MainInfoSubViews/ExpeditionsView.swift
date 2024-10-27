// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI

// MARK: - ExpeditionsView

struct ExpeditionsView: View {
    let expeditions: [any Expedition]
    var useAsyncImage: Bool = false

    @MainActor var body: some View {
        VStack {
            ForEach(expeditions, id: \.iconURL) { expedition in
                EachExpeditionView(expedition: expedition)
            }
        }
    }
}

// MARK: - EachExpeditionView

struct EachExpeditionView: View {
    let expedition: any Expedition
    let viewConfig: WidgetViewConfiguration = .defaultConfig

    @MainActor var body: some View {
        HStack {
            webView(url: expedition.iconURL)
            if let expedition = expedition as? GeneralNote4GI.ExpeditionInfo4GI.Expedition {
                VStack(alignment: .leading) {
                    Text(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: expedition.finishTime))!)
                        .lineLimit(1)
                        .font(.footnote)
                        .minimumScaleFactor(0.4)
                    let totalSecond = 20.0 * 60.0 * 60.0
                    let percentage = TimeInterval.sinceNow(to: expedition.finishTime) / totalSecond
                    percentageBar(percentage)
                        .environment(\.colorScheme, .light)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(
                        expedition.isFinished
                            ? "pzWidgetsKit.expedition.status.finished"
                            : "pzWidgetsKit.expedition.status.pending"
                    )
                    .lineLimit(1)
                    .font(.footnote)
                    .minimumScaleFactor(0.4)
                    percentageBar(1)
                        .environment(\.colorScheme, .light)
                }
            }
        }
        .foregroundColor(Color("textColor3", bundle: .main))
    }

    @ViewBuilder
    func webView(url: URL) -> some View {
        GeometryReader { g in
            AsyncImage(url: expedition.iconURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaleEffect(1.5)
            .scaledToFit()
            .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
        }
        .frame(maxWidth: 50, maxHeight: 50)
    }

    @ViewBuilder
    func percentageBar(_ percentage: Double) -> some View {
        let cornerRadius: CGFloat = 3
        GeometryReader { g in
            ZStack(alignment: .leading) {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(width: g.size.width, height: g.size.height)
                .foregroundStyle(.ultraThinMaterial)
                .opacity(0.6)
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .frame(
                    width: g.size.width * percentage,
                    height: g.size.height
                )
                .foregroundStyle(.thickMaterial)
            }
            .aspectRatio(30 / 1, contentMode: .fit)
//                .preferredColorScheme(.light)
        }
        .frame(height: 7)
    }
}
