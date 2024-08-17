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
    func asAccountMenuLabel4SUI() -> some View {
        LabeledContent {
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fontWidth(.condensed)
                Text(uidWithGame).fontDesign(.monospaced)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        } label: {
            asIcon4SUI().frame(width: 48).padding(.trailing, 4)
        }
    }
}
