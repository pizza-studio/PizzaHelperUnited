// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI

@available(watchOS, unavailable)
struct ExpeditionInfoBar: View {
    // MARK: Lifecycle

    init(dailyNote: any DailyNoteProtocol) {
        self.dailyNote = dailyNote
    }

    // MARK: Internal

    var body: some View {
        switch dailyNote {
        case _ as Note4ZZZ: EmptyView() /// ZZZ has no expedition API results.
        default:
            HStack(alignment: .center, spacing: 8) {
                dailyNote.game.expeditionAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .shadow(color: .white, radius: 1)
                    .legibilityShadow(isText: false)
                isExpeditionAllCompleteImage
                    .frame(maxWidth: 13, maxHeight: 13)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .legibilityShadow()
                let completionIntel = completionIntel
                Text(verbatim: "\(completionIntel.finished) / \(completionIntel.all)")
                    .lineLimit(1)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .font(.system(.caption, design: .rounded))
                    .minimumScaleFactor(0.2)
                    .legibilityShadow()
            }
        }
    }

    // MARK: Private

    private let dailyNote: any DailyNoteProtocol

    private var completionIntel: FieldCompletionIntel<Int> {
        dailyNote.expeditionCompletionStatus
    }

    @ViewBuilder private var isExpeditionAllCompleteImage: some View {
        let ratio = Double(completionIntel.finished) / Double(completionIntel.all)
        Image(systemSymbol: .figureWalk)
            .overlayImageWithRingProgressBar(ratio, scaler: 0.78)
    }
}
