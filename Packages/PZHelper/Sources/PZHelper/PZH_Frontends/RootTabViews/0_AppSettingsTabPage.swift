// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAboutKit
import PZBaseKit
import SwiftUI

// MARK: - AppSettingsTabPage

struct AppSettingsTabPage: View {
    // MARK: Lifecycle

    init(nav: Nav? = nil) {
        self.nav = nav
    }

    // MARK: Internal

    enum Nav: Int {
        case profileManager
        case faq
        case cloudAccountSettings
        case liveActivitySettings
        case notificationSettings
        case uiSettings
        case privacySettings
        case otherSettings
        case about
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                ASUpdateNoticeView()
                    .font(.footnote)
                Section {
                    NavigationLink(value: Nav.profileManager) {
                        Label("profileMgr.manage.title".i18nPZHelper, systemSymbol: .personTextRectangleFill)
                    }
                    NavigationLink(value: Nav.faq) {
                        Label(
                            FAQView.navTitle,
                            systemSymbol: .personFillQuestionmark
                        )
                    }
                } header: {
                    Text("settings.section.profileManagement.header".i18nPZHelper)
                        .textCase(.none)
                }

                Section {
                    AppLanguageSwitcher()
                    NavigationLink(value: Nav.uiSettings) {
                        Label("settings.uiSettings.title".i18nPZHelper, systemSymbol: .pc)
                    }
                } header: {
                    Text("settings.section.visualSettings.header".i18nPZHelper)
                        .textCase(.none)
                }

                Section {
                    NavigationLink(value: Nav.notificationSettings) {
                        Label(NotificationSettingsPageContent.navTitle, systemSymbol: .bellBadge)
                    }
                    LiveActivitySettingNavigator(selectedView: $nav)
                } header: {
                    Text(NotificationSettingsPageContent.navTitleShortened)
                        .textCase(.none)
                }

                WatchDataPusherButton()

                if Pizza.isAppStoreRelease {
                    Section {
                        ASReviewHandler.makeRatingButton()
                    } header: {
                        Text("settings.section.appStoreRelated.header".i18nPZHelper)
                            .textCase(.none)
                    }
                }

                Section {
                    NavigationLink(
                        value: Nav.privacySettings,
                        label: { Label("settings.privacy.title".i18nPZHelper, systemSymbol: .handRaisedSlashFill) }
                    )
                    NavigationLink(
                        value: Nav.about,
                        label: {
                            Label {
                                Text(verbatim: AboutView.navTitle)
                            } icon: {
                                AboutView.navIcon
                            }
                        }
                    )
                } header: {
                    Text(verbatim: "settings.section.otherSettings.header".i18nPZHelper)
                        .textCase(.none)
                }

                #if DEBUG
                Section {
                    NavigationLink(value: Nav.cloudAccountSettings) {
                        Label("# Cloud Account Settings".description, systemSymbol: .cloudCircle)
                    }
                    NavigationLink(value: Nav.otherSettings) {
                        Label("# Other Settings".description, systemSymbol: .infoSquare)
                    }
                }
                #endif
            }
            #if os(iOS) || targetEnvironment(macCatalyst)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.bordered)
            #endif
            .safeAreaInset(edge: .bottom) {
                tabNavVM.tabBarForMacCatalyst
                    .fixedSize(horizontal: false, vertical: true)
            }
            .navigationTitle("tab.settings.fullTitle".i18nPZHelper)
        } detail: {
            navigationDetail(selection: $nav)
        }
    }

    // MARK: Private

    @State private var nav: Nav?
    @State private var sharedDB = Enka.Sputnik.shared
    @StateObject private var tabNavVM = GlobalNavVM.shared

    @Default(.appLanguage) private var appLanguage: [String]?

    @ViewBuilder
    private func navigationDetail(selection: Binding<Nav?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .profileManager: ProfileManagerPageContent()
            case .faq: FAQView()
            case .cloudAccountSettings: CloudAccountSettingsPageContent()
            case .uiSettings: UISettingsPageContent()
            case .liveActivitySettings: LiveActivitySettingsPageContent()
            case .notificationSettings: NotificationSettingsPageContent()
            case .privacySettings: PrivacySettingsPageContent()
            case .otherSettings: OtherSettingsPageContent()
            case .none: UISettingsPageContent()
            case .about: AboutView()
            }
        }
    }
}
