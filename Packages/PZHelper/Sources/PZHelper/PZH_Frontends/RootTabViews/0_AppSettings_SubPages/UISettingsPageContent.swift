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
struct UISettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        Form {
            Section {
                AppWallpaperSettingsNav()
                    .alignmentGuide(.listRowSeparatorLeading) { d in
                        d[.leading]
                    }
            } header: {
                Text(AppWallpaperSettingsNav.navSectionHeader)
                    .textCase(.none)
            } footer: {
                Text(AppWallpaperSettingsNav.navDescription)
            }

            Section {
                Toggle(isOn: $restoreTabOnLaunching) {
                    Text("setting.display.restoreTabOnLaunching".i18nPZHelper)
                }
                defaultServerSelector4GI
            } header: {
                Text("settings.display.generalSettings.sectionHeader".i18nPZHelper)
            }

            Enka.DisplayOptionViewContents()
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle("settings.uiSettings.title".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
    }

    @ViewBuilder var defaultServerSelector4GI: some View {
        VStack {
            Picker(selection: $defaultServer4GI) {
                ForEach(HoYo.Server.allCases4GI) { server in
                    Text(
                        server.localizedDescriptionByGame + " (\(server.timeZone.identifier))"
                    ).tag(server.rawValue)
                }
            } label: {
                Text("settings.display.timeZone4OfficialFeedsEtc.title".i18nPZHelper)
            }
            Text("settings.display.timeZone4GI.description".i18nPZHelper)
                .asInlineTextDescription()
        }
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared

    @Default(.restoreTabOnLaunching) private var restoreTabOnLaunching: Bool
    @Default(.defaultServer) private var defaultServer4GI: String
}
