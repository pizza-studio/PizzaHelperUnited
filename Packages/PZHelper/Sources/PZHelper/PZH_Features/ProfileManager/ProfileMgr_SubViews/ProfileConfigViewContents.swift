// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileConfigViewContents

// TODO: 该页面为半成品状态，暂时仅支持对帐号内容的直接静态编辑。

/// 就是原先的 EditAccountView。
struct ProfileConfigViewContents: View {
    // MARK: Lifecycle

    public init(profile: PZProfileMO, fetchedAccounts: [FetchedAccount]? = nil) {
        self.profile = profile
        self.fetchedAccounts = fetchedAccounts
    }

    // MARK: Public

    @MainActor public var body: some View {
        RequireLoginView(
            unsavedCookie: $profile.cookie,
            unsavedFP: $profile.deviceFingerPrint,
            deviceID: $profile.deviceID,
            region: profile.server.region
        )
        Section {
            HStack {
                Text("profile.label.nickname".i18nPZHelper)
                Spacer()
                TextField(
                    "profile.label.nickname".i18nPZHelper,
                    text: $profile.name
                ).multilineTextAlignment(.trailing)
            }
            Toggle(
                "profile.label.allowNotification".i18nPZHelper,
                isOn: allowNotification
            )
        } header: {
            HStack {
                Text("UID: " + profile.uidWithGame)
                Spacer()
                Text(profile.game.localizedDescription)
                Text(profile.server.withGame(profile.game).localizedDescriptionByGame)
            }
        }

        if let fetchedAccounts {
            SelectAccountView(profile: profile, fetchedAccounts: fetchedAccounts)
        }

        Section {
            NavigationLink {
                ProfileConfigEditorView(unsavedProfile: profile)
            } label: {
                Text("profile.label.editDetails".i18nPZHelper)
            }
        }

        TestAccountSectionView(profile: profile)
    }

    // MARK: Private

    @State private var profile: PZProfileMO
    @State private var validate: String = ""
    @State private var fetchedAccounts: [FetchedAccount]?

    private var allowNotification: Binding<Bool> {
        .init {
            profile.allowNotification
        } set: { newValue in
            profile.allowNotification = newValue
        }
    }
}

// MARK: ProfileConfigViewContents.RequireLoginView

extension ProfileConfigViewContents {
    fileprivate struct RequireLoginView: View {
        @Binding var unsavedCookie: String
        @Binding var unsavedFP: String
        @Binding var deviceID: String

        @State private var isGetCookieWebViewShown: Bool = false

        let region: HoYo.AccountRegion

        @MainActor var body: some View {
            Button {
                isGetCookieWebViewShown.toggle()
            } label: {
                Text(
                    "settings.requireLoginView.loginViaMiyousheOrHoyoLab.relogin".i18nPZHelper
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
            .sheet(isPresented: $isGetCookieWebViewShown, content: handleSheetNavigation)
        }

        @ViewBuilder
        private func handleSheetNavigation() -> some View {
            switch region {
            case .hoyoLab:
                GetCookieWebView(
                    isShown: $isGetCookieWebViewShown,
                    cookie: $unsavedCookie,
                    region: region
                )
            case .miyoushe:
                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP, deviceID: $deviceID)
            }
        }
    }

    // MARK: - SelectAccountView

    fileprivate struct SelectAccountView: View {
        // MARK: Lifecycle

        init(profile: PZProfileMO, fetchedAccounts: [FetchedAccount]) {
            self._profile = State(wrappedValue: profile)
            self.fetchedAccounts = fetchedAccounts
        }

        // MARK: Internal

        @State var profile: PZProfileMO

        let fetchedAccounts: [FetchedAccount]

        @MainActor var body: some View {
            Section {
                // 如果该帐号绑定的UID不止一个，则显示Picker选择帐号
                if fetchedAccounts.count > 1 {
                    Picker("account.label.select", selection: selectedAccount) {
                        ForEach(
                            fetchedAccounts,
                            id: \.gameUid
                        ) { account in
                            Text(account.nickname + "（\(account.gameUid)）")
                                .tag(account as FetchedAccount?)
                        }
                    }
                }
            }
        }

        // MARK: Private

        @MainActor private var selectedAccount: Binding<FetchedAccount?> {
            .init {
                fetchedAccounts.first { account in
                    account.gameUid == profile.uid
                }
            } set: { account in
                if let account = account, let region = HoYo.AccountRegion(rawValue: account.gameBiz) {
                    profile.name = account.nickname
                    profile.uid = account.gameUid
                    profile.server = HoYo.Server(uid: account.gameUid, game: region.game) ?? .celestia(profile.game)
                }
            }
        }
    }
}
