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
        GachaStatsSection(
            gpid: theVM.currentGachaProfile?.asSendable,
            gachaType: theVM.currentPoolType
        )
        ForEach(theVM.cachedEntries) { entry in
            Label {
                HStack {
                    Text(entry.nameLocalized())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text(String(repeating: "★", count: entry.rarity.rawValue))
                }
            } icon: {
                entry.icon(30)
            }
        }
    }

    // MARK: Fileprivate

    @State fileprivate var enkaDB = Enka.Sputnik.shared
    @State fileprivate var metaDB = GachaMeta.sharedDB
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM
}
