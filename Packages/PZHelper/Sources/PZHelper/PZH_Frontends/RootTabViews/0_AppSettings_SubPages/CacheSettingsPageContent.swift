// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperConfigKit
import WallpaperKit

// MARK: - UISettingsPageContent

@available(iOS 17.0, macCatalyst 17.0, *)
struct CacheSettingsPageContent: View {
    static let navTitle: String = .init(
        localized: "settings.cacheSettings.navTitle", bundle: .currentSPM
    )

    var body: some View {
        Form {
            Enka.CacheSettingsViewContents4EnkaDB()
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
    }
}
