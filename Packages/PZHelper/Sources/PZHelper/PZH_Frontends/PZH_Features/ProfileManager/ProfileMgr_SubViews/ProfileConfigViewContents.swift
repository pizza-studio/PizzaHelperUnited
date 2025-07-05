// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileConfigViewContents

/// 就是原先的 EditAccountView。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct ProfileConfigViewContents: View {
    // MARK: Lifecycle

    public init(profile: PZProfileRef, fetchedAccounts: [FetchedAccount]? = nil) {
        self.profile = profile
        self.fetchedAccounts = fetchedAccounts
    }

    // MARK: Public

    public var body: some View {
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

        Section {
            TestAccountSectionView(profile: profile)
        } footer: {
            warningAboutDeviceFP
        }
    }

    // MARK: Private

    @State private var profile: PZProfileRef
    @State private var validate: String = ""
    @State private var fetchedAccounts: [FetchedAccount]?

    private var allowNotification: Binding<Bool> {
        .init {
            profile.allowNotification
        } set: { newValue in
            profile.allowNotification = newValue
        }
    }

    @ViewBuilder private var warningAboutDeviceFP: some View {
        if case .miyoushe = profile.server.region {
            Text("profile.label.fp.extraNotice.deviceFP".i18nPZHelper)
        }
    }
}

// MARK: ProfileConfigViewContents.RequireLoginView

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension ProfileConfigViewContents {
    private struct RequireLoginView: View {
        // MARK: Internal

        @Binding var unsavedCookie: String
        @Binding var unsavedFP: String
        @Binding var deviceID: String

        let region: HoYo.AccountRegion

        var body: some View {
            NavigationLink {
                handleSheetNavigation()
            } label: {
                Text(
                    "settings.requireLoginView.loginViaMiyousheOrHoyoLab.relogin".i18nPZHelper
                )
                .foregroundColor(.accentColor)
            }
        }

        // MARK: Private

        @ViewBuilder
        private func handleSheetNavigation() -> some View {
            Group {
                switch region {
                case .hoyoLab:
                    GetCookieWebView(
                        cookie: $unsavedCookie,
                        region: region
                    )
                case .miyoushe:
                    GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP, deviceID: $deviceID)
                }
            }
            // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
            .appTabBarVisibility(.hidden)
            // 逼着用户改用自订的后退按钮。
            // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
            // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - SelectAccountView

    private struct SelectAccountView: View {
        // MARK: Lifecycle

        init(profile: PZProfileRef, fetchedAccounts: [FetchedAccount]) {
            self._profile = State(wrappedValue: profile)
            self.fetchedAccounts = fetchedAccounts
        }

        // MARK: Internal

        @State var profile: PZProfileRef

        let fetchedAccounts: [FetchedAccount]

        var body: some View {
            Section {
                // 如果该账号绑定的UID不止一个，则显示Picker选择账号
                if fetchedAccounts.count > 1 {
                    Picker("profileMgr.label.select", selection: selectedAccount) {
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
