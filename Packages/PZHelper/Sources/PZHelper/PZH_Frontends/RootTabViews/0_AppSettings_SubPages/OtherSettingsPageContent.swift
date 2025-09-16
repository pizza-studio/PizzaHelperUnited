// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperConfigKit

// MARK: - OtherSettingsPageContent

@available(iOS 17.0, macCatalyst 17.0, *)
struct OtherSettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        arrangedNotificationsView
                    } label: {
                        Text(verbatim: "Arranged Notifications")
                    }
                } footer: {
                    Text(verbatim: "The Pizza Helper v\(appVersion) (\(buildVersion))")
                }
                #if DEBUG
                CGImageCropperView.makeTestView()
                #endif
            }
            .formStyle(.grouped).disableFocusable()
            .navigationTitle("Developer Settings".description)
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing4AllOS) {
                    Menu {
                        Button {
                            let profiles = Defaults[.pzProfiles]
                            Defaults.removeAll()
                            Defaults[.pzProfiles] = profiles
                            UserDefaults.baseSuite.synchronize()
                        } label: {
                            Text(verbatim: "Clean All User Defaults Key")
                        }
                    } label: {
                        Text(verbatim: "Adv.")
                    }
                }
            }
        }
    }

    // MARK: Private

    private let appVersion = (
        Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String
    ) ?? ""
    private let buildVersion = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? ""
    @State private var isAlertShow = false
    @State private var alertMessage = ""

    @ViewBuilder private var arrangedNotificationsView: some View {
        ScrollView {
            Text(alertMessage)
                .font(.footnote)
                .padding()
                .onAppear {
                    Task {
                        for message in await PZNotificationCenter.getAllNotificationsDescriptions() {
                            alertMessage += message + "\n"
                        }
                    }
                }
        }
    }
}
