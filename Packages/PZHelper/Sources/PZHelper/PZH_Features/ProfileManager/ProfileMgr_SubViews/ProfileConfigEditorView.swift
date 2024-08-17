// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

struct ProfileConfigEditorView: View {
    @Binding var unsavedProfile: PZProfileMO

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
                Picker("profile.label.game".i18nPZHelper, selection: $unsavedProfile.game) {
                    ForEach(Pizza.SupportedGame.allCases) { currentGame in
                        Text(currentGame.localizedDescription).tag(currentGame)
                    }
                }.onChange(of: unsavedProfile.game) { _, newValue in
                    switch unsavedProfile.server {
                    case .celestia: unsavedProfile.server = .celestia(newValue)
                    case .irminsul: unsavedProfile.server = .irminsul(newValue)
                    case .unitedStates: unsavedProfile.server = .unitedStates(newValue)
                    case .europe: unsavedProfile.server = .europe(newValue)
                    case .asia: unsavedProfile.server = .asia(newValue)
                    case .hkMacauTaiwan: unsavedProfile.server = .hkMacauTaiwan(newValue)
                    }
                    unsavedProfile.serverRawValue = unsavedProfile.server.rawValue
                }
                LabeledContent {
                    TextField("UID", text: $unsavedProfile.uid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: { Text("UID") }
                    .onChange(of: unsavedProfile.uid) { _, _ in
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
            } header: {
                Text("profile.label.fp".i18nPZHelper)
                    .textCase(.none)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("profile.label.editDetails".i18nPZHelper)
        .navigationBarTitleDisplayMode(.large)
    }
}
