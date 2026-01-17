// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
@preconcurrency import UserNotifications
import WallpaperConfigKit
import WallpaperKit

// MARK: - LiveActivitySettingNavigator

@available(iOS 16.2, macCatalyst 16.2, *)
struct LiveActivitySettingNavigator: View {
    // MARK: Lifecycle

    public init?() {
        guard OS.type != .macOS || Pizza.isDebug else { return nil }
    }

    // MARK: Internal

    var body: some View {
        NavigationLink(destination: LiveActivitySettingsPageContent.init) {
            Label {
                Text("settings.staminaTimer.settings.navTitle", bundle: .currentSPM)
            } icon: {
                Image(systemSymbol: .timer)
            }
        }
    }

    // MARK: Private

    @State private var isAlertShow: Bool = false
}

// MARK: - LiveActivitySettingsPageContent

@available(iOS 16.2, macCatalyst 16.2, *)
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
                    Text("settings.staminaTimer.explanation", bundle: .currentSPM)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
                if !allowLiveActivity {
                    Label {
                        Text("settings.staminaTimer.realtimeActivity.notEnabled", bundle: .currentSPM)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                    osSettingsLink
                } else {
                    Toggle(
                        isOn: $autoDeliveryStaminaTimerLiveActivity.animation()
                    ) {
                        Text("settings.staminaTimer.autoInit.toggle.title", bundle: .currentSPM)
                    }
                    Toggle(
                        isOn: $showExpeditionInLiveActivity.animation()
                    ) {
                        Text("settings.staminaTimer.showExpedition.title", bundle: .currentSPM)
                    }
                }
            } footer: {
                Text("settings.staminaTimer.dynamicIsland.howToHide.answer", bundle: .currentSPM)
            }
            Section {
                Toggle(
                    isOn: labvParser.useEmptyBackground.animation()
                ) {
                    Text("settings.staminaTimer.useTransparentBackground.title", bundle: .currentSPM)
                }
                if !labvParser.useEmptyBackground.wrappedValue {
                    Toggle(
                        isOn: labvParser.useRandomBackground.animation()
                    ) {
                        Text("settings.staminaTimer.randomBackground.title", bundle: .currentSPM)
                    }
                    if !labvParser.useRandomBackground.wrappedValue {
                        NavigationLink {
                            LiveActivityBackgroundPicker()
                        } label: {
                            Text("settings.staminaTimer.background.choose", bundle: .currentSPM)
                        }
                    }
                }
            } header: {
                Text("settings.staminaTimer.background.navTitle".i18nWPConfKit)
            }
        }
        .formStyle(.grouped).disableFocusable()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
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
        if OS.type == .macOS {
            EmptyView()
        } else {
            #if canImport(UIKit)
            Link(destination: URL(
                string: UIApplication
                    .openSettingsURLString
            )!) {
                Text("settings.staminaTimer.gotoSystemSettings", bundle: .currentSPM)
            }
            #else
            EmptyView()
            #endif
        }
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
