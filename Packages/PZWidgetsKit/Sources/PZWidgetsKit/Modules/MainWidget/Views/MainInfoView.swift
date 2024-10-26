// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - MainInfo

struct MainInfo: View {
    let entry: any TimelineEntry
    let dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    let accountNameTest = "account.manage.title"

    @MainActor var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                let staminaIntel = dailyNote.staminaIntel
                Text(staminaIntel.existing.description)
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color("textColor3"))
                    .shadow(radius: 1)
                Image("树脂")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .shadow(radius: 0.8)
            }
            Spacer()
            HStack {
                Button(intent: WidgetRefreshIntent()) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .foregroundColor(Color("textColor3"))
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                RecoveryTimeText(entry: entry, data: dailyNote)
            }
        }
    }
}

// MARK: - WidgetRefreshIntent

struct WidgetRefreshIntent: AppIntent {
    static let title: LocalizedStringResource = "WidgetRefreshIntent.Refresh"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
