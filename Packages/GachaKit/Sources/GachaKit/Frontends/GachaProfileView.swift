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

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        ForEach(entries) { entry in
            let expressible = GachaItemExpressible(rawEntry: entry)
            LabeledContent {
                Text(expressible.nameLocalized())
                    .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                expressible.icon(30)
            }
        }
    }

    // MARK: Fileprivate

    @State fileprivate var enkaDB = Enka.Sputnik.shared
    @State fileprivate var metaDB = GachaMeta.sharedDB
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM

    @Query(
        filter: PZGachaEntryMO.predicate(owner: GachaVM.shared.currentGachaProfile),
        sort: [SortDescriptor(\PZGachaEntryMO.id, order: .reverse)]
    ) fileprivate var entries: [PZGachaEntryMO]
}

extension PZGachaEntryMO {
    public static func predicate(
        owner gachaProfile: PZGachaProfileMO?
    )
        -> Predicate<PZGachaEntryMO> {
        guard let gachaProfile else { return #Predicate<PZGachaEntryMO> { _ in false } }
        let matchedGame = gachaProfile.game.rawValue
        let matchedUID = gachaProfile.uid
        return #Predicate<PZGachaEntryMO> { entry in
            entry.uid == matchedUID && entry.game == matchedGame
        }
    }
}
