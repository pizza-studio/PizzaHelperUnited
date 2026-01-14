// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 16.2, macCatalyst 16.2, *)
extension ProfileProtocol {
    @MainActor @ViewBuilder
    func asIcon4SUI() -> some View {
        if #available(iOS 17.0, macCatalyst 17.0, *) {
            Enka.ProfileIconView(uid: uid, game: game)
        } else {
            AnonymousIconView.rawImage4SUI
                .clipShape(.circle)
                .contentShape(.circle)
                .saturation(0)
                .colorMultiply({
                    switch game {
                    case .genshinImpact: .purple
                    case .starRail: .pink
                    case .zenlessZone: .orange
                    }
                }())
        }
    }

    @MainActor
    func asTinyMenuLabelText() -> String {
        if OS.type == .macOS {
            name + " // \(uidWithGame)"
        } else {
            name + "\n\(uidWithGame)"
        }
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
