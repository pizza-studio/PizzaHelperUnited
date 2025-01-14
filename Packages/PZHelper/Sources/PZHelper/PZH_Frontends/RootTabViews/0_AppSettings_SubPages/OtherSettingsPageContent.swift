// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - OtherSettingsPageContent

struct OtherSettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        let profiles = Defaults[.pzProfiles]
                        Defaults.removeAll()
                        Defaults[.pzProfiles] = profiles
                        UserDefaults.baseSuite.synchronize()
                    } label: {
                        Text(verbatim: "Clean All User Defaults Key")
                    }
                }
                Section {
                    NavigationLink {
                        arrangedNotificationsView
                    } label: {
                        Text(verbatim: "Arranged Notifications")
                    }
                } footer: {
                    Text(verbatim: "The Pizza Helper v\(appVersion) (\(buildVersion))")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Develop Settings".description)
            .navBarTitleDisplayMode(.large)
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
