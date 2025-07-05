// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension ProfileProtocol {
    @MainActor @ViewBuilder
    func asIcon4SUI() -> some View {
        Enka.ProfileIconView(uid: uid, game: game)
    }

    @MainActor @ViewBuilder
    func asMenuLabel4SUI() -> some View {
        switch OS.type {
        case .macOS:
            Text(name + " // \(uidWithGame)")
        default:
            Label {
                Text(name + "\n\(uidWithGame)")
            } icon: {
                asIcon4SUI()
            }
        }
    }
}
