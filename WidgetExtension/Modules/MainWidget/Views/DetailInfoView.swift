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

    var lineHeightMax: CGFloat { 17 }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if dailyNote.hasDailyTaskIntel {
                DailyTaskInfoBar(dailyNote: dailyNote)
                    .frame(maxHeight: lineHeightMax)
            }
            switch dailyNote {
            case let dailyNote as any Note4GI:
                if dailyNote.homeCoinInfo.maxHomeCoin != 0 {
                    GIHomeCoinInfoBar(homeCoinInfo: dailyNote.homeCoinInfo)
                        .frame(maxHeight: lineHeightMax)
                }

                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                        .frame(maxHeight: lineHeightMax)
                }

                if let dailyNote = dailyNote as? FullNote4GI {
                    if dailyNote.transformerInfo.obtained, viewConfig.showTransformer {
                        GITransformerInfoBar(transformerInfo: dailyNote.transformerInfo)
                            .frame(maxHeight: lineHeightMax)
                    }
                    switch viewConfig.trounceBlossomDisplayMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted where !dailyNote.weeklyBossesInfo.allDiscountsAreUsedUp:
                        GITrounceBlossomInfoBar(
                            weeklyBossesInfo: dailyNote.weeklyBossesInfo
                        )
                        .frame(maxHeight: lineHeightMax)
                    case .alwaysShow:
                        GITrounceBlossomInfoBar(weeklyBossesInfo: dailyNote.weeklyBossesInfo)
                            .frame(maxHeight: lineHeightMax)
                    default: EmptyView()
                    }
                }
            case let dailyNote as Note4HSR:
                HSRReservedTBPowerInfoBar(tbPowerIntel: dailyNote.staminaInfo)
                    .frame(maxHeight: lineHeightMax)
                if dailyNote.hasExpeditions {
                    ExpeditionInfoBar(dailyNote: dailyNote)
                        .frame(maxHeight: lineHeightMax)
                }
                HSRSimulUnivInfoBar(dailyNote: dailyNote)
                    .frame(maxHeight: lineHeightMax)
                if let eowIntel = dailyNote.echoOfWarIntel {
                    switch viewConfig.echoOfWarDisplayMethod {
                    case .neverShow:
                        EmptyView()
                    case .disappearAfterCompleted where !eowIntel.allRewardsClaimed:
                        HSREchoOfWarInfoBar(eowIntel: eowIntel)
                            .frame(maxHeight: lineHeightMax)
                    case .alwaysShow:
                        HSREchoOfWarInfoBar(eowIntel: eowIntel)
                            .frame(maxHeight: lineHeightMax)
                    default: EmptyView()
                    }
                }
            case let dailyNote as Note4ZZZ:
                ZZZScratchCardInfoBar(data: dailyNote)
                    .frame(maxHeight: lineHeightMax)
                ZZZVHSStoreInfoBar(data: dailyNote)
                    .frame(maxHeight: lineHeightMax)
                ZZZBountyInfoBar(data: dailyNote)
                    .frame(maxHeight: lineHeightMax)
                ZZZInvestigationPointInfoBar(data: dailyNote)
                    .frame(maxHeight: lineHeightMax)
            default:
                EmptyView()
            }
        }
        .padding(.trailing)
    }
}
