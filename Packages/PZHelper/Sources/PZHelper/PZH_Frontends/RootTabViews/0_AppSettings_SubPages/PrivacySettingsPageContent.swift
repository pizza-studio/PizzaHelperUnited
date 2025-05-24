// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

struct PrivacySettingsPageContent: View {
    var body: some View {
        List {
            Text("settings.privacy.noOptionsAvailable", bundle: .module)
                .asInlineTextDescription()
        }
        .navigationTitle("settings.privacy.title".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
    }
}
