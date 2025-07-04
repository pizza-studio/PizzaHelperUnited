// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import SwiftUI

// MARK: - OtherSettingsPageContent

struct CloudAccountSettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        PZAccountMODebugView()
            .navigationTitle("# CloudKit Debug".description)
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
}
