// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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
            MetaBar4GIRealmCurrency(note: self)
            if dailyNote.hasExpeditions {
                MetaBar4Expedition(note: self)
            }
            if viewConfig.showTransformer {
                MetaBar4GITransformer(note: self)
            }
            switch viewConfig.trounceBlossomDisplayMethod {
            case .disappearAfterCompleted:
                MetaBar4WeeklyBosses(note: self, disappearIfAllCompleted: true)
            case .alwaysShow:
                MetaBar4WeeklyBosses(note: self)
            case .neverShow: .none
            }
        case let dailyNote as any Note4HSR:
            MetaBar4HSRReservedTBPower(note: self)
            if dailyNote.hasExpeditions {
                MetaBar4Expedition(note: self)
            }
            MetaBar4HSRSimulUniv(note: self)
            switch viewConfig.echoOfWarDisplayMethod {
            case .disappearAfterCompleted:
                MetaBar4WeeklyBosses(note: self, disappearIfAllCompleted: true)
            case .alwaysShow:
                MetaBar4WeeklyBosses(note: self)
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
