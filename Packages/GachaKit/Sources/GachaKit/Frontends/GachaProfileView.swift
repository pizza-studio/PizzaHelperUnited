// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaProfileView

public struct GachaProfileView: View {
    // MARK: Lifecycle

    public init(givenGPID: GachaProfileID) {
        self.givenGPID = givenGPID
        switch givenGPID.game {
        case .genshinImpact: self.poolType = .giCharacterEventWish
        case .starRail: self.poolType = .srCharacterEventWarp
        case .zenlessZone: self.poolType = .zzExclusiveChannel
        }
        _entries = Query(
            filter: PZGachaEntryMO.predicate(owner: GachaVM.shared.currentGachaProfile),
            sort: [SortDescriptor(\PZGachaEntryMO.id, order: .reverse)],
            animation: .default
        )
    }

    // MARK: Public

    @MainActor public var body: some View {
        GachaStatisticSectionView(gpid: givenGPID, gachaType: poolType)
//        ForEach(entries) { entry in
//            let expressible = GachaItemExpressible(rawEntry: entry)
//            LabeledContent {
//                Text(expressible.nameLocalized())
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            } label: {
//                expressible.icon(30)
//            }
//        }
    }

    // MARK: Fileprivate

    fileprivate let givenGPID: GachaProfileID
    @State fileprivate var enkaDB = Enka.Sputnik.shared
    @State fileprivate var metaDB = GachaMeta.sharedDB
    @State fileprivate var poolType: GachaPoolExpressible
    @Query fileprivate var entries: [PZGachaEntryMO]
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM
}
