// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import SwiftUI

@MainActor
struct AppSettingsPage: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Enka.DisplayOptionViewContents()
            }
            .formStyle(.grouped)
            .navigationTitle("tab.settings.fullTitle".i18nPZHelper)
        }
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
}
