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

    public init(profile: PZProfileMO) {
        self.profile = profile
    }

    // MARK: Public

    public var body: some View {
        RequireLoginView(
            unsavedCookie: $profile.cookie,
            unsavedFP: $profile.deviceFingerPrint,
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
                Text(profile.server.localizedDescriptionByGame)
            }
        }

        // if let accountsForSelected = accountsForSelected {
        //     SelectAccountView(account: account, accountsForSelected: accountsForSelected)
        // }

        Section {
            NavigationLink {
                ProfileConfigEditorView(unsavedAccount: $profile)
            } label: {
                Text("profile.label.editDetails".i18nPZHelper)
            }
        }

        // TestAccountSectionView(account: account)
    }

    // MARK: Private

    @State private var profile: PZProfileMO
    // private var profilesForSelected: [FetchedAccount]?
    @State private var validate: String = ""

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

        @State private var isGetCookieWebViewShown: Bool = false

        let region: HoYo.AccountRegion

        var body: some View {
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
            //        .sheet(isPresented: $isGetCookieWebViewShown, content: {
            //            switch region {
            //            case .mainlandChina:
            //                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP)
            //            case .global:
            //                GetCookieWebView(
            //                    isShown: $isGetCookieWebViewShown,
            //                    cookie: $unsavedCookie,
            //                    region: region
            //                )
            //            }
            //        })
        }
    }
}
