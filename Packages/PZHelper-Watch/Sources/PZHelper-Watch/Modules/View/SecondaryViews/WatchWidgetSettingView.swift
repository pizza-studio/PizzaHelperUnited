// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - WatchWidgetSettingView

@available(watchOS 10.0, *)
struct WatchWidgetSettingView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                ForEach(theVM.profiles) { profile in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(profile.name).bold()
                            Text(profile.uidWithGame).font(.footnote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemSymbol: .chevronLeft)
                            .foregroundStyle(.secondary)
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
                .onDelete(perform: deleteItems)
            } header: {
                Text("watch.profile.manage.title", bundle: .module)
                    .textCase(.none)
            }
        }
    }

    // MARK: Private

    @StateObject private var theVM: ProfileManagerVM = .shared

    @Default(.pzProfiles) private var pzProfiles: [String: PZProfileSendable]

    /// 该方法是 SwiftUI 内部 Protocol 规定的方法。
    private func deleteItems(offsets: IndexSet) {
        deleteItems(offsets: offsets, clearEnkaCache: false)
    }

    private func deleteItems(offsets: IndexSet, clearEnkaCache: Bool) {
        var uuidsToDrop: Set<UUID> = []
        var profilesToDrop: Set<PZProfileSendable> = []
        offsets.forEach {
            let returned = theVM.profiles[$0]
            profilesToDrop.insert(returned)
            uuidsToDrop.insert(returned.uuid)
        }
        deleteItems(uuids: uuidsToDrop, clearEnkaCache: clearEnkaCache)
    }

    private func deleteItems(uuids uuidsToDrop: Set<UUID>, clearEnkaCache: Bool) {
        theVM.deleteProfiles(uuids: uuidsToDrop)
    }
}
