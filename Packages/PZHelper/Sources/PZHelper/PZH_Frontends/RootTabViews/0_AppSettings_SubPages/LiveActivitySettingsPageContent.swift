// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
@preconcurrency import UserNotifications
import WallpaperKit

// MARK: - LiveActivitySettingNavigator

struct LiveActivitySettingNavigator: View {
    // MARK: Lifecycle

    public init?(selectedView: Binding<AppSettingsTabPage.Nav?>) {
        self._selectedView = selectedView
        #if !DEBUG && (os(macOS) || targetEnvironment(macCatalyst))
        return nil
        #endif
    }

    // MARK: Internal

    var body: some View {
        NavigationLink(value: AppSettingsTabPage.Nav.liveActivitySettings) {
            Label {
                Text("settings.resinTimer.settings.navTitle", bundle: .module)
            } icon: {
                Image(systemSymbol: .timer)
            }
        }
    }

    // MARK: Private

    @Binding private var selectedView: AppSettingsTabPage.Nav?

    @State private var isAlertShow: Bool = false
}

// MARK: - LiveActivitySettingsPageContent

struct LiveActivitySettingsPageContent: View {
    // MARK: Internal

    @Environment(\.scenePhase) var scenePhase

    @Default(.resinRecoveryLiveActivityUseEmptyBackground) var resinRecoveryLiveActivityUseEmptyBackground: Bool
    @Default(.resinRecoveryLiveActivityUseCustomizeBackground) var resinRecoveryLiveActivityUseCustomizeBackground: Bool
    @Default(.autoDeliveryResinTimerLiveActivity) var autoDeliveryResinTimerLiveActivity: Bool
    @Default(.resinRecoveryLiveActivityShowExpedition) var resinRecoveryLiveActivityShowExpedition: Bool
    @Default(.autoUpdateResinRecoveryTimerUsingReFetchData) var autoUpdateResinRecoveryTimerUsingReFetchData: Bool

    var useRandomBackground: Binding<Bool> {
        .init {
            !resinRecoveryLiveActivityUseCustomizeBackground
        } set: { newValue in
            resinRecoveryLiveActivityUseCustomizeBackground = !newValue
        }
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemSymbol: .timer)
                        .resizable()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 64, height: 64)
                        .padding(8)
                    Text("settings.resinTimer.explanation", bundle: .module)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
                if !allowLiveActivity {
                    Label {
                        Text("settings.resinTimer.realtimeActivity.notEnabled", bundle: .module)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                    osSettingsLink
                } else {
                    Toggle(
                        isOn: $autoDeliveryResinTimerLiveActivity.animation()
                    ) {
                        Text("settings.resinTimer.autoInit.toggle.title", bundle: .module)
                    }
                    Toggle(
                        isOn: $resinRecoveryLiveActivityShowExpedition.animation()
                    ) {
                        Text("settings.resinTimer.showExpedition.title", bundle: .module)
                    }
                }
            } footer: {
                Text("settings.resinTimer.dynamicIsland.howToHide.answer", bundle: .module)
            }
            Section {
                Toggle(
                    isOn: $resinRecoveryLiveActivityUseEmptyBackground.animation()
                ) {
                    Text("settings.resinTimer.useTransparentBackground.title", bundle: .module)
                }
                if !resinRecoveryLiveActivityUseEmptyBackground {
                    Toggle(
                        isOn: useRandomBackground.animation()
                    ) {
                        Text("settings.resinTimer.randomBackground.title", bundle: .module)
                    }
                    if resinRecoveryLiveActivityUseCustomizeBackground {
                        NavigationLink {
                            LiveActivityBackgroundPicker()
                        } label: {
                            Text("settings.resinTimer.background.choose", bundle: .module)
                        }
                    }
                }
            } header: {
                Text("settings.resinTimer.background.navTitle".i18nWPKit)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                let link = "https://gi.pizzastudio.org/static/resin_timer_help.html"

                Link(destination: link.asURL) {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
        }
        .navigationTitle("settings.resinTimer.settings.navTitle".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation {
                allowLiveActivity = ResinRecoveryActivityController.shared
                    .allowLiveActivity
            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue != oldValue {
                syncLiveActivityToggleSettings()
            }
        }
    }

    // MARK: Private

    @State private var isHowToCloseDynamicIslandAlertShow: Bool = false

    @State private var allowLiveActivity: Bool = ResinRecoveryActivityController.shared.allowLiveActivity

    @ViewBuilder private var osSettingsLink: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        EmptyView()
        #else
        Link(destination: URL(
            string: UIApplication
                .openSettingsURLString
        )!) {
            Text("settings.resinTimer.gotoSystemSettings", bundle: .module)
        }
        #endif
    }

    private func syncLiveActivityToggleSettings() {
        Task { @MainActor in
            await UNUserNotificationCenter.current().notificationSettings()
            withAnimation {
                allowLiveActivity =
                    ResinRecoveryActivityController
                        .shared.allowLiveActivity
            }
        }
    }
}
