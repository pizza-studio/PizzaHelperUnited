// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZBaseKit
import SwiftUI

// MARK: - AppSettingsTabPage

struct AppSettingsTabPage: View {
    // MARK: Internal

    enum Nav {
        case profileManager
        case cloudAccountSettings
        case uiSettings
        case otherSettings
    }

    @MainActor var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                Section {
                    NavigationLink(value: Nav.profileManager) {
                        Label("profileMgr.manage.title".i18nPZHelper, systemSymbol: .personTextRectangleFill)
                    }
                } header: {
                    Text("settings.section.profileManagement.header".i18nPZHelper)
                }

                Section {
                    #if !targetEnvironment(macCatalyst) && os(iOS)
                    Button {
                        UIApplication.shared.open(UIApplication.openSettingsURLString.asURL)
                    } label: {
                        Label {
                            Text("settings.appLanguage.title".i18nPZHelper)
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemSymbol: .globe)
                        }
                    }
                    #elseif canImport(UIKit, _version: 18.0)
                    /// 這個語言選擇器用 Xcode 15 建置的話是無效的。
                    VStack {
                        Picker(selection: $appLanguage) {
                            Text("app.language.followSystemDefault".i18nBaseKit).tag([String]?.none)
                            ForEach(AppLanguage.allCases) { appLang in
                                Text(appLang.localizedDescription).tag(appLang.savedValue)
                            }
                        } label: {
                            HStack {
                                Image(systemSymbol: .globe)
                                Text("settings.appLanguage.title".i18nPZHelper)
                            }
                        }
                        Text("settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper)
                            .font(.footnote).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    #endif
                    NavigationLink(value: Nav.uiSettings) {
                        Label("settings.uiSettings.title".i18nPZHelper, systemSymbol: .pc)
                    }
                } header: {
                    Text("settings.section.visualSettings.header".i18nPZHelper)
                }

                #if DEBUG
                Section {
                    NavigationLink(value: Nav.cloudAccountSettings) {
                        Label("# Cloud Account Settings".description, systemSymbol: .cloudCircle)
                    }
                    NavigationLink(value: Nav.otherSettings) {
                        Label("# Other Settings".description, systemSymbol: .infoSquare)
                    }
                } header: {
                    Text(verbatim: "# Other Settings")
                }
                #endif
            }
            #if os(iOS) || targetEnvironment(macCatalyst)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.bordered)
            #endif
            .navigationTitle("tab.settings.fullTitle".i18nPZHelper)
        } detail: {
            navigationDetail(selection: $nav)
        }
    }

    // MARK: Private

    @State private var nav: Nav?
    @State private var sharedDB = Enka.Sputnik.shared

    @Default(.appLanguage) private var appLanguage: [String]?

    @ViewBuilder
    private func navigationDetail(selection: Binding<Nav?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .profileManager: ProfileManagerPageContent()
            case .cloudAccountSettings: CloudAccountSettingsPageContent()
            case .uiSettings: UISettingsPageContent()
            case .otherSettings: OtherSettingsPageContent()
            case .none: UISettingsPageContent()
            }
        }
    }
}
