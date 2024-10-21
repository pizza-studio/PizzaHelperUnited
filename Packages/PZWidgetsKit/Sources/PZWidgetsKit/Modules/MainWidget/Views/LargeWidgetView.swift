// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LargeWidgetView

struct LargeWidgetView: View {
    let entry: any TimelineEntry
    var dailyNote: any Note4GI
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    mainInfo()
                    Spacer(minLength: 18)
                    detailInfo()
                }

                Spacer(minLength: 30)
                VStack(alignment: .leading) {
                    ExpeditionsView(
                        expeditions: dailyNote.expeditionInfo4GI.expeditions
                    )
                    if viewConfig.showMaterialsInLargeSizeWidget {
                        Spacer(minLength: 15)
                        MaterialView()
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    func mainInfo() -> some View {
        VStack(alignment: .leading, spacing: 5) {
//            Spacer()
            if let accountName = accountName {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                    Text(accountName)
                }
                .font(.footnote)
                .foregroundColor(Color("textColor3"))
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(dailyNote.resinInfo.calculatedCurrentResin(referTo: entry.date))")
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
            HStack {
                Image("hourglass.circle")
                    .foregroundColor(Color("textColor3"))
                    .font(.title3)
                RecoveryTimeText(entry: entry, resinInfo: dailyNote.resinInfo)
            }
        }
    }

    @ViewBuilder
    func detailInfo() -> some View {
        VStack(alignment: .leading, spacing: 17) {
            if dailyNote.homeCoinInformation.maxHomeCoin != 0 {
                HomeCoinInfoBar(entry: entry, homeCoinInfo: dailyNote.homeCoinInformation)
            }

            if dailyNote.dailyTaskInformation.totalTaskCount != 0 {
                DailyTaskInfoBar(dailyTaskInfo: dailyNote.dailyTaskInformation)
            }

            if dailyNote.expeditionInfo4GI.maxExpeditionsCount != 0 {
                ExpeditionInfoBar(
                    expeditionInfo: dailyNote.expeditionInfo4GI
                )
            }

            if let dailyNote = dailyNote as? GeneralNote4GI {
                if dailyNote.transformerInformation.obtained, viewConfig.showTransformer {
                    TransformerInfoBar(transformerInfo: dailyNote.transformerInformation)
                }
                switch viewConfig.weeklyBossesShowingMethod {
                case .neverShow:
                    EmptyView()
                case .disappearAfterCompleted:
                    if dailyNote.weeklyBossesInformation.remainResinDiscount != 0 {
                        WeeklyBossesInfoBar(
                            weeklyBossesInfo: dailyNote.weeklyBossesInformation
                        )
                    }
                case .alwaysShow, .unknown:
                    WeeklyBossesInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInformation)
                }
            }
        }
        .padding(.trailing)
    }
}
