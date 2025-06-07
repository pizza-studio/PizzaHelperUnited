// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - MetaBar

public protocol MetaBar {
    nonisolated init?(note: any DailyNoteProtocol)

    nonisolated var note: any DailyNoteProtocol { get }
    nonisolated var labelIcon4SUI: Image { get }
    nonisolated var statusIcon4SUI: Image { get }
    nonisolated var statusTextUnits4SUI: [Text] { get }
    nonisolated var completionStatusRatio: Double { get }
    nonisolated var game: Pizza.SupportedGame { get }
}

extension MetaBar {
    nonisolated private var maxStatusIconDimension: CGFloat { 13 }
    nonisolated private var statusIconInnerScale: CGFloat { 0.78 }

    nonisolated private var completionStatusRatioSafe: CGFloat {
        Swift.min(1, Swift.max(0, completionStatusRatio))
    }
}

@MainActor
extension MetaBar {
    @ViewBuilder public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            labelIcon4SUI
                .resizable()
                .scaledToFit()
                .legibilityShadow(isText: false)
            statusIcon4SUI
                .overlayImageWithRingProgressBar(
                    completionStatusRatioSafe, scaler: statusIconInnerScale
                )
                .frame(maxWidth: 13, maxHeight: 13)
                .legibilityShadow(isText: true)
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                statusTextUnits4SUI
                    .reduce(Text(verbatim: ""), +)
                    .lineLimit(1)
            }
            .allowsTightening(true)
            .legibilityShadow(isText: true)
            .font(.system(.caption))
            .minimumScaleFactor(0.2)
            .legibilityShadow(isText: true)
        }
        .foregroundStyle(.primary)
        .environment(\.colorScheme, .dark)
    }
}
