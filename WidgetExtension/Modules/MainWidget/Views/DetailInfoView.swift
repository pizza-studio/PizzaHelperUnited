// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - DetailInfo

@available(watchOS, unavailable)
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

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            switch dailyNote {
            case let dailyNote as any Note4GI:
                drawDailyTaskCompletionStatus()
                if dailyNote.homeCoinInfo.maxHomeCoin != 0 {
                    GIHomeCoinInfoBar(homeCoinInfo: dailyNote.homeCoinInfo)
                }

                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }

                if let dailyNote = dailyNote as? FullNote4GI {
                    if dailyNote.transformerInfo.obtained, viewConfig.showTransformer {
                        GITransformerInfoBar(transformerInfo: dailyNote.transformerInfo)
                    }
                    switch viewConfig.trounceBlossomDisplayMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted where !dailyNote.weeklyBossesInfo.allDiscountsAreUsedUp:
                        GITrounceBlossomInfoBar(
                            weeklyBossesInfo: dailyNote.weeklyBossesInfo
                        )
                    case .alwaysShow:
                        GITrounceBlossomInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInfo)
                    default: EmptyView()
                    }
                }
            case let dailyNote as Note4HSR:
                HSRReservedTBPowerInfoBar(tbPowerIntel: dailyNote.staminaInfo)
                drawDailyTaskCompletionStatus()
                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                }
                HSRSimulUnivInfoBar(dailyNote: dailyNote)
                if let eowIntel = dailyNote.echoOfWarIntel {
                    switch viewConfig.echoOfWarDisplayMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted where !eowIntel.allRewardsClaimed:
                        HSREchoOfWarInfoBar(eowIntel: eowIntel)
                    case .alwaysShow:
                        HSREchoOfWarInfoBar(eowIntel: eowIntel)
                    default: EmptyView()
                    }
                }
            case let dailyNote as Note4ZZZ:
                drawDailyTaskCompletionStatus()
                ZZZScratchCardInfoBar(data: dailyNote)
                ZZZVHSStoreInfoBar(data: dailyNote)
                ZZZBountyInfoBar(data: dailyNote)
                ZZZInvestigationPointInfoBar(data: dailyNote)
            default:
                EmptyView()
            }
        }
        .padding(.trailing)
    }

    // MARK: Private

    @ViewBuilder
    private func drawDailyTaskCompletionStatus() -> some View {
        if dailyNote.hasDailyTaskIntel {
            DailyTaskInfoBar(dailyNote: dailyNote)
        }
    }
}
