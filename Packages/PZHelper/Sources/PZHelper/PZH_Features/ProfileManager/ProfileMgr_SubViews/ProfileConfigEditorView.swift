// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

struct ProfileConfigEditorView: View {
    @Binding var unsavedAccount: PZProfileMO

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    TextField(
                        "profile.label.nickname".i18nPZHelper,
                        text: $unsavedAccount.name,
                        prompt: Text("profile.label.nickname".i18nPZHelper)
                    )
                    .multilineTextAlignment(.trailing)
                } label: { Text("profile.label.nickname".i18nPZHelper) }
                Picker("profile.label.game".i18nPZHelper, selection: $unsavedAccount.game) {
                    ForEach(Pizza.SupportedGame.allCases) { currentGame in
                        Text(currentGame.localizedDescription).tag(currentGame)
                    }
                }.onChange(of: unsavedAccount.game) { _, newValue in
                    switch unsavedAccount.server {
                    case .celestia: unsavedAccount.server = .celestia(newValue)
                    case .irminsul: unsavedAccount.server = .irminsul(newValue)
                    case .unitedStates: unsavedAccount.server = .unitedStates(newValue)
                    case .europe: unsavedAccount.server = .europe(newValue)
                    case .asia: unsavedAccount.server = .asia(newValue)
                    case .hkMacauTaiwan: unsavedAccount.server = .hkMacauTaiwan(newValue)
                    }
                    unsavedAccount.serverRawValue = unsavedAccount.server.rawValue
                }
                LabeledContent {
                    TextField("UID", text: $unsavedAccount.uid, prompt: Text("UID"))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: { Text("UID") }
                Picker("profile.label.server".i18nPZHelper, selection: $unsavedAccount.server) {
                    switch unsavedAccount.game {
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
                TextEditor(text: $unsavedAccount.cookie)
                    .frame(height: cookieTextEditorFrame)
            } header: {
                Text("profile.label.cookie".i18nPZHelper)
                    .textCase(.none)
            }
            Section {
                TextField("profile.label.fp".i18nPZHelper, text: $unsavedAccount.deviceFingerPrint)
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
