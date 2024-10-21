// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - DetailInfo

struct DetailInfo: View {
    let entry: any TimelineEntry
    let dailyNote: any Note4GI
    let viewConfig: WidgetViewConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
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
