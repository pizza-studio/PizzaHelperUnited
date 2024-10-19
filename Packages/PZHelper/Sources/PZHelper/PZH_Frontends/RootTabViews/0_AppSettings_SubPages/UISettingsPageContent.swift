// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import PZAccountKit
import SwiftUI
import WallpaperKit

// MARK: - UISettingsPageContent

struct UISettingsPageContent: View {
    // MARK: Internal

    @MainActor var body: some View {
        Form {
            Section {
                AppWallpaperSettingsPicker()
                    .alignmentGuide(.listRowSeparatorLeading) { d in
                        d[.leading]
                    }
                Toggle(isOn: $restoreTabOnLaunching) {
                    Text("setting.display.restoreTabOnLaunching".i18nPZHelper)
                }
                defaultServerSelector4GI
            } header: {
                Text("settings.display.generalSettings.sectionHeader".i18nPZHelper)
            }

            Enka.DisplayOptionViewContents()
        }
        .formStyle(.grouped)
        .navigationTitle("settings.uiSettings.title".i18nPZHelper)
    }

    @MainActor @ViewBuilder var defaultServerSelector4GI: some View {
        VStack {
            Picker(selection: $defaultServer4GI) {
                ForEach(HoYo.Server.allCases4GI) { server in
                    Text(
                        server.localizedDescriptionByGame + " (\(server.timeZone.identifier))"
                    ).tag(server.rawValue)
                }
            } label: {
                Text("settings.display.timeZone4GI.title".i18nPZHelper)
            }
            Text("settings.display.timeZone4GI.description".i18nPZHelper)
                .font(.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
    @Default(.restoreTabOnLaunching) private var restoreTabOnLaunching: Bool
    @Default(.background4App) private var background4App: Wallpaper
    @Default(.defaultServer) private var defaultServer4GI: String
}
