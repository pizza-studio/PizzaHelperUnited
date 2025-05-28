// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

struct PFMgrAdvancedOptionsView: View {
    // MARK: Public

    public static let navTitle = "settings.profile.advanced.navTitle".i18nPZHelper

    public var body: some View {
        Form {
            Section {
                Picker(selection: $situatePZProfileDBIntoGroupContainer) {
                    Text(
                        "settings.profile.advanced.dbSaveLocation.toGroupContainer",
                        bundle: .module
                    ).tag(true)
                    Text(
                        "settings.profile.advanced.dbSaveLocation.toAppContainer",
                        bundle: .module
                    ).tag(false)
                } label: {
                    Text(
                        "settings.profile.advanced.dbSaveLocation.title",
                        bundle: .module
                    )
                }
                .onChange(of: situatePZProfileDBIntoGroupContainer) { _, _ in
                    alertPresented.toggle()
                }
            } header: {
                Text(verbatim: "SwiftData™").textCase(.none)
            } footer: {
                Text(
                    "settings.profile.advanced.dbSaveLocation.footer",
                    bundle: .module
                )
            }
            .alert(
                "settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper,
                isPresented: $alertPresented
            ) {
                Button("sys.ok".i18nBaseKit) {
                    exit(0)
                }
            } message: {
                Text("settings.profile.advanced.dbSaveLocation.restartRequired.description", bundle: .module)
            }

            Section {
                Toggle(isOn: $automaticallyDeduplicatePZProfiles) {
                    Text(
                        "settings.profile.advanced.autoDeduplication.title",
                        bundle: .module
                    )
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
    }

    // MARK: Private

    @Default(.automaticallyDeduplicatePZProfiles) private var automaticallyDeduplicatePZProfiles: Bool
    @Default(.situatePZProfileDBIntoGroupContainer) private var situatePZProfileDBIntoGroupContainer: Bool
    @State private var alertPresented: Bool = false
}
