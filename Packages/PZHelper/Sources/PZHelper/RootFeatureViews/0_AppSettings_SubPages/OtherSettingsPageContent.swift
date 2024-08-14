// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import SwiftUI

// MARK: - OtherSettingsPageContent

@MainActor
struct OtherSettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        Form {
            Text(verbatim: "UNDER_CONSTRUCTION")
        }
        .formStyle(.grouped)
        .navigationTitle("settings.uiSettings.title".i18nPZHelper)
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
}
