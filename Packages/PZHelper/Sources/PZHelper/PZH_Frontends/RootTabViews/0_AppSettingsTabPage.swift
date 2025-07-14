// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAboutKit
import PZBaseKit
import SwiftUI

// MARK: - AppSettingsTabPage

@available(iOS 17.0, macCatalyst 17.0, *)
struct AppSettingsTabPage: View {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                ASUpdateNoticeView()
                    .font(.footnote)
                Section {
                    NavigationLink(destination: ProfileManagerPageContent.init) {
                        Label("profileMgr.manage.title".i18nPZHelper, systemSymbol: .personTextRectangleFill)
                    }
                    NavigationLink(destination: FAQView.init) {
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
                    NavigationLink(destination: UISettingsPageContent.init) {
                        Label("settings.uiSettings.title".i18nPZHelper, systemSymbol: .pc)
                    }
                } header: {
                    Text("settings.section.visualSettings.header".i18nPZHelper)
                        .textCase(.none)
                }

                Section {
                    NavigationLink(destination: NotificationSettingsPageContent.init) {
                        Label(NotificationSettingsPageContent.navTitle, systemSymbol: .bellBadge)
                    }
                    LiveActivitySettingNavigator()
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
                        destination: PrivacySettingsPageContent.init,
                        label: { Label("settings.privacy.title".i18nPZHelper, systemSymbol: .handRaisedSlashFill) }
                    )
                    NavigationLink(
                        destination: AboutView.init,
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
                    NavigationLink(destination: ContentView4iOS14.init) {
                        Label("# Refugee View Test".description, systemSymbol: .figureWalkDiamond)
                    }
                    NavigationLink(destination: CloudAccountSettingsPageContent.init) {
                        Label("# Cloud Account Settings".description, systemSymbol: .cloudCircle)
                    }
                    NavigationLink(destination: OtherSettingsPageContent.init) {
                        Label("# Other Settings".description, systemSymbol: .infoSquare)
                    }
                }
                #endif
            }
            .formStyle(.grouped)
            .navigationTitle("tab.settings.fullTitle".i18nPZHelper)
            .navBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                rootNavVM.iOSBottomTabBarForBuggyOS25ReleasesOn
            }
        }
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
    @State private var rootNavVM = RootNavVM.shared

    @Default(.appLanguage) private var appLanguage: [String]?
}
