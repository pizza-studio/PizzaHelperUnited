// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - DetailInfo

struct DetailInfo: View {
    // MARK: Lifecycle

    init(
        entry: any TimelineEntry,
        dailyNote: any DailyNoteProtocol,
        viewConfig: WidgetViewConfiguration,
        spacing: CGFloat = 13
    ) {
        self.entry = entry
        self.dailyNote = dailyNote
        self.viewConfig = viewConfig
        self.spacing = spacing
    }

    // MARK: Internal

    let entry: any TimelineEntry
    let dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let spacing: CGFloat

    @MainActor var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            switch dailyNote {
            case let dailyNote as any Note4GI:
                if dailyNote.homeCoinInfo.maxHomeCoin != 0, let gNote = dailyNote as? GeneralNote4GI {
                    HomeCoinInfoBar(entry: entry, homeCoinInfo: gNote.homeCoinInfo)
                }

                if dailyNote.dailyTaskInfo.totalTaskCount != 0 {
                    DailyTaskInfoBar(dailyNote: dailyNote)
                }

                if dailyNote.expeditions.maxExpeditionsCount != 0 {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }

                if let dailyNote = dailyNote as? GeneralNote4GI {
                    if dailyNote.transformerInfo.obtained, viewConfig.showTransformer {
                        TransformerInfoBar(transformerInfo: dailyNote.transformerInfo)
                    }
                    switch viewConfig.weeklyBossesShowingMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted:
                        if dailyNote.weeklyBossesInfo.remainResinDiscount != 0 {
                            WeeklyBossesInfoBar(
                                weeklyBossesInfo: dailyNote.weeklyBossesInfo
                            )
                        }
                    case .alwaysShow:
                        WeeklyBossesInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInfo)
                    }
                }
            case let dailyNote as Note4HSR:
                if let dailyNote = dailyNote as? WidgetNote4HSR, dailyNote.assignmentInfo.totalAssignmentNumber != 0 {
                    DailyTaskInfoBar(dailyNote: dailyNote)
                }
                if dailyNote.assignmentInfo.totalAssignmentNumber != 0 {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }
            // TODO: 模擬宇宙，等。
            case let dailyNote as Note4ZZZ:
                // TODO: 刮刮乐，等。
                EmptyView()
            default:
                EmptyView()
            }
        }
        .padding(.trailing)
    }
}
