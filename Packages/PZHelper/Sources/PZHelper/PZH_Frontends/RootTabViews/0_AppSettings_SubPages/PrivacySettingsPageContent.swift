// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import PZHoYoLabKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
struct PrivacySettingsPageContent: View {
    var body: some View {
        Form {
            Text("settings.privacy.noOptionsAvailable", bundle: .currentSPM)
                .asInlineTextDescription()
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle("settings.privacy.title".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
    }
}
