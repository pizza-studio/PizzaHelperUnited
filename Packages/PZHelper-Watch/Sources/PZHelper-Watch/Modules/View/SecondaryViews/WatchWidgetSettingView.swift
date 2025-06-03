// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - WatchWidgetSettingView

struct WatchWidgetSettingView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                ForEach(profiles) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name).bold()
                            Text(account.uidWithGame).font(.footnote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemSymbol: .chevronLeft)
                            .foregroundStyle(.secondary)
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
                .onDelete(perform: { indexSet in
                    for offset in indexSet {
                        let account = profiles[offset]
                        let uuidToRemove = account.uuid
                        PZNotificationCenter.deleteDailyNoteNotification(for: account.asSendable)
                        modelContext.delete(account)
                        do {
                            try modelContext.save()
                            Defaults[.pzProfiles].removeValue(forKey: uuidToRemove.uuidString)
                            UserDefaults.profileSuite.synchronize()
                        } catch {
                            print(error)
                        }
                    }
                })
            } header: {
                Text("watch.profile.manage.title", bundle: .module)
                    .textCase(.none)
            }
        }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
}
