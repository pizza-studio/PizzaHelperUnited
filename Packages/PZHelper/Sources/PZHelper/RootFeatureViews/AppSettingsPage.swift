// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import SwiftUI

// MARK: - AppSettingsPage

@MainActor
struct AppSettingsPage: View {
    // MARK: Internal

    enum Nav {
        case uiSettings
        case otherSettings
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                NavigationLink(value: Nav.uiSettings) {
                    Label("settings.uiSettings.title".i18nPZHelper, systemSymbol: .pc)
                }
                NavigationLink(value: Nav.otherSettings) {
                    Label("UNDER_CONSTRUCTION".i18nPZHelper, systemSymbol: .infoSquare)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("tab.settings.fullTitle".i18nPZHelper)
        } detail: {
            navigationDetail(selection: $nav)
        }
    }

    // MARK: Private

    @State private var nav: Nav?
    @State private var sharedDB = Enka.Sputnik.shared

    @ViewBuilder
    private func navigationDetail(selection: Binding<Nav?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .uiSettings: UISettingsPageContent()
            case .otherSettings: OtherSettingsPageContent()
            case .none: UISettingsPageContent()
            }
        }
    }
}

// MARK: - UISettingsPageContent

@MainActor
struct UISettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        Form {
            Enka.DisplayOptionViewContents()
        }
        .formStyle(.grouped)
        .navigationTitle("settings.uiSettings.title".i18nPZHelper)
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
}

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
