// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

extension PZProfileMO {
    @ViewBuilder @MainActor
    func asIcon4SUI() -> some View {
        Enka.ProfileIconView(uid: uid, game: game)
    }

    @ViewBuilder @MainActor
    func asMenuLabel4SUI() -> some View {
        Label {
            #if targetEnvironment(macCatalyst)
            Text(name + " // \(uidWithGame)")
            #else
            Text(name + "\n\(uidWithGame)")
            #endif
        } icon: {
            asIcon4SUI()
        }
    }
}
