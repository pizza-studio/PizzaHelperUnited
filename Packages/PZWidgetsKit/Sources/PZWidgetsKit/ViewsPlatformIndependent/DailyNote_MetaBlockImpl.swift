// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

@available(iOS 16.2, macCatalyst 16.2, *)
extension DailyNoteProtocol {
    public func getMetaBlockContents(
        config: WidgetViewConfig? = nil
    )
        -> [MetaBar] {
        getMetaBlockContentsNullable(config: config).compactMap(\.self)
    }

    @ArrayBuilder<MetaBar?>
    private func getMetaBlockContentsNullable(
        config: WidgetViewConfig? = nil
    )
        -> [MetaBar?] {
        let viewConfig = config ?? .defaultConfig
        if hasDailyTaskIntel {
            MetaBar4DailyTask(note: self)
        }
        switch self {
        case let dailyNote as any Note4GI:
            MetaBar4GIRealmCurrency(note: dailyNote)
            if dailyNote.hasExpeditions {
                MetaBar4Expedition(note: dailyNote)
            }
            if viewConfig.showTransformer {
                MetaBar4GITransformer(note: dailyNote)
            }
            switch viewConfig.trounceBlossomDisplayMethod {
            case .disappearAfterCompleted:
                MetaBar4WeeklyBosses(note: dailyNote, disappearIfAllCompleted: true)
            case .alwaysShow:
                MetaBar4WeeklyBosses(note: dailyNote)
            case .neverShow: .none
            }
        case let dailyNote as any Note4HSR:
            MetaBar4HSRReservedTBPower(note: dailyNote)
            MetaBar4HSRCosmicStrife(note: dailyNote)
            switch viewConfig.echoOfWarDisplayMethod {
            case .disappearAfterCompleted:
                MetaBar4WeeklyBosses(note: dailyNote, disappearIfAllCompleted: true)
            case .alwaysShow:
                MetaBar4WeeklyBosses(note: dailyNote)
            case .neverShow: .none
            }
        case let dailyNote as Note4ZZZ:
            MetaBar4ZZZScratchCard(note: dailyNote)
            MetaBar4ZZZVHSStore(note: dailyNote)
            MetaBar4ZZZBounty(note: dailyNote)
            MetaBar4ZZZInvestigationPoint(note: dailyNote)
        default:
            .none
        }
    }
}
