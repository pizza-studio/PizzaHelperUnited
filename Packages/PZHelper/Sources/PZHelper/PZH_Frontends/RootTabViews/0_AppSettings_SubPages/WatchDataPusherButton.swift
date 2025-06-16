// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

struct WatchDataPusherButton: View {
    // MARK: Lifecycle

    init?() {
        #if !canImport(WatchConnectivity)
        return nil
        #endif
    }

    // MARK: Internal

    var body: some View {
        #if canImport(WatchConnectivity)
        if AppleWatchSputnik.isSupported {
            Section {
                Button {
                    var profileInfo = "settings.appleWatchPusher.force_push.received".i18nPZHelper
                    profileInfo += "\n"
                    for profile in theVM.profiles {
                        profileInfo += "\(profile.name) (\(profile.uidWithGame))\n"
                    }
                    AppleWatchSputnik.shared.sendAccounts(
                        theVM.profiles,
                        profileInfo
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
        #else
        EmptyView()
        #endif
    }

    // MARK: Private

    @StateObject private var theVM: ProfileManagerVM = .shared
}
