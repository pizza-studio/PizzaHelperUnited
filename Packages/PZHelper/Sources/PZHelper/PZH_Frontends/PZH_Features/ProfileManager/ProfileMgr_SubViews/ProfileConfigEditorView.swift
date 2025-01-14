// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileConfigEditorView

struct ProfileConfigEditorView: View {
    // MARK: Internal

    @Bindable var unsavedProfile: PZProfileMO

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    TextField(
                        "profile.label.nickname".i18nPZHelper,
                        text: $unsavedProfile.name,
                        prompt: Text("profile.label.nickname".i18nPZHelper)
                    )
                    .multilineTextAlignment(.trailing)
                } label: { Text("profile.label.nickname".i18nPZHelper) }
                LabeledContent("profile.label.game".i18nPZHelper) {
                    Picker("".description, selection: $unsavedProfile.game) {
                        ForEach(Pizza.SupportedGame.allCases) { currentGame in
                            Text(currentGame.localizedDescriptionTrimmed)
                                .tag(currentGame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fontWidth(.condensed)
                    .fixedSize()
                }.onChange(of: unsavedProfile.game, initial: true) { _, newValue in
                    unsavedProfile.server.changeGame(to: newValue)
                    unsavedProfile.serverRawValue = unsavedProfile.server.rawValue
                }
                LabeledContent {
                    TextField("UID".description, text: $unsavedProfile.uid, prompt: Text(verbatim: "UID"))
                    #if os(iOS) || targetEnvironment(macCatalyst)
                        .keyboardType(.numberPad)
                    #endif
                        .multilineTextAlignment(.trailing)
                } label: { Text(verbatim: "UID") }
                    .onChange(of: unsavedProfile.uid, initial: true) { _, _ in
                        let server = HoYo.Server(uid: unsavedProfile.uid, game: unsavedProfile.game)
                        guard let server else { return }
                        unsavedProfile.server = server
                    }
                Picker("profile.label.server".i18nPZHelper, selection: $unsavedProfile.server) {
                    switch unsavedProfile.game {
                    case .genshinImpact:
                        ForEach(HoYo.Server.allCases4GI) { server in
                            Text(server.localizedDescriptionByGameAndRegion).tag(server)
                        }
                    case .starRail:
                        ForEach(HoYo.Server.allCases4HSR) { server in
                            Text(server.localizedDescriptionByGameAndRegion).tag(server)
                        }
                    case .zenlessZone:
                        ForEach(HoYo.Server.allCases4ZZZ) { server in
                            Text(server.localizedDescriptionByGameAndRegion).tag(server)
                        }
                    }
                }
            }

            Section {
                let cookieTextEditorFrame: CGFloat = 150
                TextEditor(text: $unsavedProfile.cookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("profile.label.cookie".i18nPZHelper)
                    .textCase(.none)
            }
            Section {
                TextField("profile.label.fp".i18nPZHelper, text: $unsavedProfile.deviceFingerPrint)
                    .multilineTextAlignment(.leading)
                RegenerateDeviceFingerPrintButton(profile: unsavedProfile)
            } header: {
                Text("profile.label.fp".i18nPZHelper)
                    .textCase(.none)
            } footer: {
                warningAboutDeviceFP
            }
        }
        .formStyle(.grouped)
        .navigationTitle("profile.label.editDetails".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
    }

    // MARK: Private

    private var sTokenBinding: Binding<String> {
        .init(
            get: { unsavedProfile.sTokenV2 ?? "" },
            set: { unsavedProfile.sTokenV2 = $0 }
        )
    }

    @ViewBuilder private var warningAboutDeviceFP: some View {
        if unsavedProfile.game == .zenlessZone, case .miyoushe = unsavedProfile.server.region {
            Text("profile.label.fp.extraNotice.zzz".i18nPZHelper)
                .foregroundStyle(.orange)
        }
    }

    private func requiresSTokenV2(for region: HoYo.AccountRegion) -> Bool {
        switch region {
        case .hoyoLab: false
        case .miyoushe: false
            // 注：这个功能是否有用，得再讨论。目前似乎只有刚刚登入时抓到的 STokenV2 是正确可用的。
        }
    }
}

// MARK: - RegenerateDeviceFingerPrintButton

private struct RegenerateDeviceFingerPrintButton: View {
    // MARK: Lifecycle

    init(profile: PZProfileMO) {
        self._profile = State(wrappedValue: profile)
    }

    // MARK: Internal

    enum Status {
        case pending
        case progress(Task<Void, Never>)
        case succeed
        case fail(Error)
    }

    @State var profile: PZProfileMO

    @State var isErrorAlertShown: Bool = false
    @State var error: AnyLocalizedError?

    @State var status: Status = .pending

    var body: some View {
        Button {
            if case let .progress(task) = status {
                task.cancel()
            }
            let task = Task {
                do {
                    Defaults[.lastDefaultFingerprintRefreshDate] = .now
                    profile.deviceFingerPrint = try await HoYo.getDeviceFingerPrint(
                        region: profile.server.region,
                        deviceID: profile.deviceID
                    ).deviceFP
                    status = .succeed
                } catch {
                    status = .fail(error)
                    self.error = AnyLocalizedError(error)
                }
            }
            status = .progress(task)
        } label: {
            let labelText = "profileMgr.regenerateDeviceFingerPrint.label".i18nPZHelper
            switch status {
            case .pending: Text(labelText)
            case .progress: ProgressView()
            case .succeed:
                Label {
                    Text(labelText)
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundStyle(.green)
                }
            case .fail:
                Label {
                    Text(labelText)
                } icon: {
                    Image(systemSymbol: .xmarkCircle)
                        .foregroundStyle(.red)
                }
            }
        }
        .disabled({ if case .progress = status { true } else { false }}())
        .alert(isPresented: $isErrorAlertShown, error: error) { _ in
            Button("sys.done".i18nBaseKit) { isErrorAlertShown = false }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
