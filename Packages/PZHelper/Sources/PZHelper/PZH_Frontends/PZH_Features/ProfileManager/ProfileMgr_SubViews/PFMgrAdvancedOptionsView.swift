// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
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
                        bundle: .currentSPM
                    ).tag(true)
                    Text(
                        "settings.profile.advanced.dbSaveLocation.toAppContainer",
                        bundle: .currentSPM
                    ).tag(false)
                } label: {
                    Text(
                        "settings.profile.advanced.dbSaveLocation.title",
                        bundle: .currentSPM
                    )
                }
                .react(to: situatePZProfileDBIntoGroupContainer) { _, _ in
                    alertPresented.toggle()
                }
            } header: {
                if #available(iOS 17.0, macCatalyst 17.0, *) {
                    Text(verbatim: "SwiftData™").textCase(.none)
                } else {
                    Text(verbatim: "CoreData™").textCase(.none)
                }
            } footer: {
                Text(
                    "settings.profile.advanced.dbSaveLocation.footer",
                    bundle: .currentSPM
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
                Text("settings.profile.advanced.dbSaveLocation.restartRequired.description", bundle: .currentSPM)
            }

            Section {
                Toggle(isOn: $automaticallyDeduplicatePZProfiles) {
                    Text(
                        "settings.profile.advanced.autoDeduplication.title",
                        bundle: .currentSPM
                    )
                }
            }

            Section {
                TextField(text: $recentlyPropagatedDeviceFingerprint) {
                    Text(verbatim: "x-rpc-device_fp")
                        .textCase(nil)
                        .fontDesign(.monospaced)
                }
                .autocorrectionDisabled(true)
                .react(to: recentlyPropagatedDeviceFingerprint) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    formatDeviceFingerprint()
                }
                #if !(os(macOS) || targetEnvironment(macCatalyst))
                .keyboardType(.asciiCapable)
                #endif
                Button {
                    Task {
                        do {
                            try await theVM.profileActor?.propagateDeviceFingerprint(
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
                        bundle: .currentSPM
                    )
                }
                .disabled(recentlyPropagatedDeviceFingerprint.isEmpty)
            } header: {
                Text(verbatim: "x-rpc-device_fp")
            } footer: {
                Text(
                    "settings.profile.advanced.fingerprintPropagation.footer",
                    bundle: .currentSPM
                )
            }

            #if targetEnvironment(simulator)
            Section {
                TextEditor(text: $clipboardJSONText)
                    .fontDesign(.monospaced)
                    .autocorrectionDisabled(true)
                #if !(os(macOS) || targetEnvironment(macCatalyst))
                    .keyboardType(.asciiCapable)
                #endif
                    .frame(minHeight: 100)
                Button {
                    let text = clipboardJSONText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty, let jsonData = text.data(using: .utf8) else {
                        simpleTaptic(type: .error)
                        alertToastEventStatus.isFailureSituationTriggered.toggle()
                        return
                    }
                    Task {
                        do {
                            var decodedProfiles = try JSONDecoder().decode(
                                [PZProfileSendable].self, from: jsonData
                            )
                            decodedProfiles.fixPrioritySettings(
                                respectExistingPriority: true, delta: theVM.profiles.count
                            )
                            try await theVM.profileActor?.addOrUpdateProfiles(Set(decodedProfiles))
                            clipboardJSONText = ""
                            simpleTaptic(type: .success)
                            alertToastEventStatus.isProfileTaskSucceeded.toggle()
                        } catch {
                            simpleTaptic(type: .error)
                            alertToastEventStatus.isFailureSituationTriggered.toggle()
                        }
                    }
                } label: {
                    Text(verbatim: "Read JSON from Clipboard")
                }
                .disabled(clipboardJSONText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } header: {
                Text(verbatim: "Batch Import via Clipboard (Simulator Only)")
            }
            #endif
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
        .toast(isPresenting: $alertToastEventStatus.isDeviceFPPropagationSucceeded) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "profileMgr.toast.taskSucceeded".i18nPZHelper
            )
        }
        .toast(isPresenting: $alertToastEventStatus.isProfileTaskSucceeded) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "profileMgr.toast.taskSucceeded".i18nPZHelper
            )
        }
        .toast(isPresenting: $alertToastEventStatus.isFailureSituationTriggered) {
            AlertToast(
                displayMode: .alert,
                type: .error(.red),
                title: "profileMgr.toast.taskFailed".i18nPZHelper
            )
        }
    }

    // MARK: Private

    @Default(.automaticallyDeduplicatePZProfiles) private var automaticallyDeduplicatePZProfiles: Bool
    @Default(.situatePZProfileDBIntoGroupContainer) private var situatePZProfileDBIntoGroupContainer: Bool
    @Default(.recentlyPropagatedDeviceFingerprint) private var recentlyPropagatedDeviceFingerprint
    @Environment(AlertToastEventStatus.self) private var alertToastEventStatus: AlertToastEventStatus
    @State private var theVM: ProfileManagerVM = .shared
    @State private var alertPresented: Bool = false
    @State private var clipboardJSONText: String = ""

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
