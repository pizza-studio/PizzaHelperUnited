// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
@preconcurrency import UserNotifications
import WallpaperConfigKit
import WallpaperKit

// MARK: - LiveActivitySettingNavigator

@available(iOS 17.0, macCatalyst 17.0, *)
struct LiveActivitySettingNavigator: View {
    // MARK: Lifecycle

    public init?() {
        #if !DEBUG && (os(macOS) || targetEnvironment(macCatalyst))
        return nil
        #endif
    }

    // MARK: Internal

    var body: some View {
        NavigationLink(destination: LiveActivitySettingsPageContent.init) {
            Label {
                Text("settings.staminaTimer.settings.navTitle", bundle: .module)
            } icon: {
                Image(systemSymbol: .timer)
            }
        }
    }

    // MARK: Private

    @State private var isAlertShow: Bool = false
}

// MARK: - LiveActivitySettingsPageContent

@available(iOS 17.0, macCatalyst 17.0, *)
struct LiveActivitySettingsPageContent: View {
    // MARK: Internal

    @Environment(\.scenePhase) var scenePhase

    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>
    @Default(.autoDeliveryStaminaTimerLiveActivity) var autoDeliveryStaminaTimerLiveActivity: Bool
    @Default(.showExpeditionInLiveActivity) var showExpeditionInLiveActivity: Bool

    var labvParser: LiveActivityBackgroundValueParser { .init($liveActivityWallpaperIDs) }

    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemSymbol: .timer)
                        .resizable()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 64, height: 64)
                        .padding(8)
                    Text("settings.staminaTimer.explanation", bundle: .module)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
                if !allowLiveActivity {
                    Label {
                        Text("settings.staminaTimer.realtimeActivity.notEnabled", bundle: .module)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                    osSettingsLink
                } else {
                    Toggle(
                        isOn: $autoDeliveryStaminaTimerLiveActivity.animation()
                    ) {
                        Text("settings.staminaTimer.autoInit.toggle.title", bundle: .module)
                    }
                    Toggle(
                        isOn: $showExpeditionInLiveActivity.animation()
                    ) {
                        Text("settings.staminaTimer.showExpedition.title", bundle: .module)
                    }
                }
            } footer: {
                Text("settings.staminaTimer.dynamicIsland.howToHide.answer", bundle: .module)
            }
            Section {
                Toggle(
                    isOn: labvParser.useEmptyBackground.animation()
                ) {
                    Text("settings.staminaTimer.useTransparentBackground.title", bundle: .module)
                }
                if !labvParser.useEmptyBackground.wrappedValue {
                    Toggle(
                        isOn: labvParser.useRandomBackground.animation()
                    ) {
                        Text("settings.staminaTimer.randomBackground.title", bundle: .module)
                    }
                    if !labvParser.useRandomBackground.wrappedValue {
                        NavigationLink {
                            LiveActivityBackgroundPicker()
                        } label: {
                            Text("settings.staminaTimer.background.choose", bundle: .module)
                        }
                    }
                }
            } header: {
                Text("settings.staminaTimer.background.navTitle".i18nWPConfKit)
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
        .navigationTitle("settings.staminaTimer.settings.navTitle".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation {
                allowLiveActivity = StaminaLiveActivityController.shared
                    .allowLiveActivity
            }
        }
        .react(to: scenePhase) { oldValue, newValue in
            if newValue != oldValue {
                syncLiveActivityToggleSettings()
            }
        }
    }

    // MARK: Private

    @State private var isHowToCloseDynamicIslandAlertShow: Bool = false
    @State private var allowLiveActivity: Bool = StaminaLiveActivityController.shared.allowLiveActivity

    @ViewBuilder private var osSettingsLink: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        EmptyView()
        #else
        Link(destination: URL(
            string: UIApplication
                .openSettingsURLString
        )!) {
            Text("settings.staminaTimer.gotoSystemSettings", bundle: .module)
        }
        #endif
    }

    private func syncLiveActivityToggleSettings() {
        Task { @MainActor in
            await UNUserNotificationCenter.current().notificationSettings()
            withAnimation {
                allowLiveActivity =
                    StaminaLiveActivityController
                        .shared.allowLiveActivity
            }
        }
    }
}
