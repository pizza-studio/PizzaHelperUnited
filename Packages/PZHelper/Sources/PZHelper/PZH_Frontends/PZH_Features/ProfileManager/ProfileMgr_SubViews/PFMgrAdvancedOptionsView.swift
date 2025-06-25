// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

struct PFMgrAdvancedOptionsView: View {
    // MARK: Public

    public static let navTitle = "settings.profile.advanced.navTitle".i18nPZHelper

    public var body: some View {
        @Bindable var alertToastEventStatus = alertToastEventStatus
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

            Section {
                TextField(text: $recentlyPropagatedDeviceFingerprint) {
                    Text(verbatim: "x-rpc-device_fp")
                        .textCase(nil)
                        .fontDesign(.monospaced)
                }
                .onChange(of: recentlyPropagatedDeviceFingerprint) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    formatDeviceFingerprint()
                }
                #if !os(macOS) && !targetEnvironment(macCatalyst)
                .keyboardType(.asciiCapable)
                #endif
                Button {
                    Task {
                        do {
                            try await PZProfileActor.shared.propagateDeviceFingerprint(
                                recentlyPropagatedDeviceFingerprint
                            )
                            simpleTaptic(type: .success)
                            alertToastEventStatus.isDeviceFPPropagationSucceeded.toggle()
                        } catch {
                            simpleTaptic(type: .error)
                        }
                    }
                } label: {
                    Text(
                        "settings.profile.advanced.fingerprintPropagation.buttonTitle",
                        bundle: .module
                    )
                }
                .disabled(recentlyPropagatedDeviceFingerprint.isEmpty)
            } header: {
                Text(verbatim: "x-rpc-device_fp")
            } footer: {
                Text(
                    "settings.profile.advanced.fingerprintPropagation.footer",
                    bundle: .module
                )
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
        .toast(isPresenting: $alertToastEventStatus.isDeviceFPPropagationSucceeded) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "profileMgr.toast.taskSucceeded".i18nPZHelper
            )
        }
    }

    // MARK: Private

    @Default(.automaticallyDeduplicatePZProfiles) private var automaticallyDeduplicatePZProfiles: Bool
    @Default(.situatePZProfileDBIntoGroupContainer) private var situatePZProfileDBIntoGroupContainer: Bool
    @Default(.recentlyPropagatedDeviceFingerprint) private var recentlyPropagatedDeviceFingerprint
    @Environment(AlertToastEventStatus.self) private var alertToastEventStatus
    @State private var alertPresented: Bool = false

    private func formatDeviceFingerprint() {
        let pattern = "[^a-z0-9]+"
        let toHandle = recentlyPropagatedDeviceFingerprint.replacingOccurrences(
            of: pattern,
            with: "",
            options: [.regularExpression]
        )
        // 仅当结果相异时，才会写入。
        if recentlyPropagatedDeviceFingerprint != toHandle {
            recentlyPropagatedDeviceFingerprint = toHandle
        }
    }
}
