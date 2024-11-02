// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

struct WatchDataPusherButton: View {
    // MARK: Internal

    var body: some View {
        if AppleWatchSputnik.isSupported {
            Section {
                Button {
                    var accountInfo = "settings.appleWatchPusher.force_push.received".i18nPZHelper
                    accountInfo += "\n"
                    for account in pzProfiles {
                        accountInfo += "\(account.name) (\(account.uidWithGame))\n"
                    }
                    AppleWatchSputnik.shared.sendAccounts(
                        pzProfiles.map(\.asSendable),
                        accountInfo
                    )
                } label: {
                    Label(
                        "settings.appleWatchPusher.force_push".i18nPZHelper,
                        systemSymbol: .applewatch
                    )
                }
            } header: {
                Text(verbatim: "Apple Watch™").textCase(.none)
            } footer: {
                Text("settings.appleWatchPusher.force_push.footer".i18nPZHelper)
                    .textCase(.none)
            }
        }
    }

    // MARK: Private

    @Query(sort: \PZProfileMO.priority) private var pzProfiles: [PZProfileMO]
}
