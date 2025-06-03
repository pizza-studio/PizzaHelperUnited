// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - MainInfo

@available(watchOS, unavailable)
struct MainInfo: View {
    let entry: MainWidgetProvider.Entry
    let dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    let accountNameTest = "account.manage.title"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                        .legibilityShadow(isText: false)
                    Text(accountName)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .fixedSize()
                        .minimumScaleFactor(0.5)
                        .legibilityShadow()
                }
                .font(.footnote)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                let staminaIntel = dailyNote.staminaIntel
                Text(staminaIntel.finished.description)
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .legibilityShadow()
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .legibilityShadow(isText: false)
            }
            Spacer()
            HStack {
                Button(intent: WidgetRefreshIntent(dailyNoteUIDWithGame: entry.profile?.uidWithGame)) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .legibilityShadow()
                RecoveryTimeText(entry: entry, data: dailyNote)
            }
        }
    }
}
