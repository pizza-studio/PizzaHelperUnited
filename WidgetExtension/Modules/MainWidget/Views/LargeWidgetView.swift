// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

@available(watchOS, unavailable)
struct LargeWidgetView: View {
    let entry: MainWidgetProvider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?
    let events: [EventModel]

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                mainInfo()
                Spacer(minLength: 18)
                DetailInfo(entry: entry, dailyNote: dailyNote, viewConfig: viewConfig, spacing: 17)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            /// 绝区零没有探索派遣。
            if dailyNote.game != .zenlessZone {
                Spacer()
                VStack(alignment: .leading) {
                    ExpeditionsView(
                        expeditions: dailyNote.expeditionTasks,
                        pilotAssetMap: entry.pilotAssetMap
                    )
                    Spacer(minLength: 15)
                    if dailyNote.game == .genshinImpact, viewConfig.showMaterialsInLargeSizeWidget {
                        MaterialView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            if family == .systemExtraLarge {
                officialFeedBlock()
                    .frame(width: 300)
            }
            Spacer()
        }
        .padding()
    }

    // MARK: Private

    private var weekday: String {
        let formatter = DateFormatter.CurrentLocale()
        formatter.dateFormat = "E" // Shortened weekday format
        formatter.locale = Locale.current // Use the system's current locale
        return formatter.string(from: Date())
    }

    private var dayOfMonth: String {
        let formatter = DateFormatter.CurrentLocale()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }

    @ViewBuilder
    private func officialFeedBlock() -> some View {
        VStack(alignment: .trailing) {
            OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: false
            )
            .padding(.leading, 20)
            Spacer()
            WeekdayDisplayView()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func mainInfo() -> some View {
        VStack(alignment: .leading, spacing: 5) {
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
                .foregroundColor(Color("textColor3", bundle: .main))
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(verbatim: "\(dailyNote.staminaIntel.finished)")
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(Color("textColor3", bundle: .main))
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
            HStack {
                Button(intent: WidgetRefreshIntent(dailyNoteUIDWithGame: entry.profile?.uidWithGame)) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .foregroundColor(Color("textColor3", bundle: .main))
                        .clipShape(.circle)
                        .legibilityShadow()
                }
                .buttonStyle(.plain)
                RecoveryTimeText(entry: entry, data: dailyNote)
            }
        }
    }
}
