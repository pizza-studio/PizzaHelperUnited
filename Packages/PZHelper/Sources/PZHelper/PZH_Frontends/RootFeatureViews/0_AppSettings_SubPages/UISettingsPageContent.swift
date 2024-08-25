// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import SwiftUI
import WallpaperKit

// MARK: - UISettingsPageContent

struct UISettingsPageContent: View {
    // MARK: Internal

    @MainActor var body: some View {
        Form {
            Section {
                Toggle(isOn: $restoreTabOnLaunching) {
                    Text("setting.display.restoreTabOnLaunching".i18nPZHelper)
                }
                AppWallpaperSettingsPicker()
            } header: {
                Text("settings.display.generalSettings.sectionHeader".i18nPZHelper)
            }

            Enka.DisplayOptionViewContents()
        }
        .formStyle(.grouped)
        .navigationTitle("settings.uiSettings.title".i18nPZHelper)
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
    @Default(.restoreTabOnLaunching) private var restoreTabOnLaunching: Bool
    @Default(.background4App) private var background4App: Wallpaper
}
