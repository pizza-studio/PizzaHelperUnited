// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AccountWithdrawalView

@available(iOS 16.2, macCatalyst 16.2, *)
struct HoYoPassWithdrawView: View {
    // MARK: Public

    @ViewBuilder public static var linksForManagingHoYoLabAccounts: some View {
        Link(destination: URL(string: "https://user.mihoyo.com/")!) {
            Text("sys.server.cn".i18nPZHelper) + Text(verbatim: " - ") + Text("accountRegion.name.miyoushe".i18nAK)
        }
        Link(destination: URL(string: "https://account.hoyoverse.com/")!) {
            Text("sys.server.os".i18nPZHelper) + Text(verbatim: " - ") + Text("accountRegion.name.hoyoLab".i18nAK)
        }
    }

    // MARK: Internal

    var body: some View {
        let urlStrHoYoLab = "https://account.hoyoverse.com/#/account/safetySettings"
        let urlStrMiyoushe = "https://user.mihoyo.com/#/account/closeAccount"
        Form {
            Section {
                Label {
                    HStack {
                        Text("profileMgr.withdrawal.warning".i18nPZHelper)
                            .foregroundStyle(.red)
                    }
                } icon: {
                    Image(systemSymbol: .exclamationmarkOctagonFill)
                        .foregroundStyle(.red)
                }
                .font(.headline)
            } footer: {
                VStack(alignment: .leading) {
                    Text("profileMgr.withdrawal.warning.footer".i18nPZHelper)
                    Text("profileMgr.withdrawal.whyAddedThisPage.description".i18nPZHelper)
                }.multilineTextAlignment(.leading)
            }

            Section {
                Link(destination: URL(string: Self.hoyolabStorePage)!) {
                    Text(verbatim: "HoYoLAB on App Store")
                }
                NavigationLink {
                    WebBrowserView(url: urlStrHoYoLab)
                        .navigationTitle("profileMgr.withdrawal.navTitle.hoyolab".i18nPZHelper)
                        .navBarTitleDisplayMode(.inline)
                } label: {
                    Text("sys.server.os".i18nPZHelper) + Text(verbatim: " - HoYoLAB")
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text("profileMgr.withdrawal.linkTo:\(urlStrHoYoLab)", bundle: .currentSPM)
                    Text("profileMgr.withdrawal.readme.hoyolab.specialNotice".i18nPZHelper)
                }
            }

            Section {
                if Self.isMiyousheInstalled {
                    Link(destination: URL(string: Self.miyousheHeader + "me")!) {
                        Text("profileMgr.account.qr_code_login.open_miyoushe".i18nPZHelper)
                    }
                } else {
                    Link(destination: URL(string: Self.miyousheStorePage)!) {
                        Text("profileMgr.account.qr_code_login.open_miyoushe_mas_page".i18nPZHelper)
                    }
                }
                NavigationLink {
                    WebBrowserView(url: urlStrMiyoushe)
                        .navigationTitle("profileMgr.withdrawal.navTitle.miyoushe".i18nPZHelper)
                        .navBarTitleDisplayMode(.inline)
                } label: {
                    Text("sys.server.cn".i18nPZHelper)
                        + Text(verbatim: " - ")
                        + Text(HoYo.AccountRegion.miyoushe(.genshinImpact).localizedDescription)
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text("profileMgr.withdrawal.linkTo:\(urlStrMiyoushe)", bundle: .currentSPM)
                    Text("profileMgr.withdrawal.readme.miyoushe.specialNotice".i18nPZHelper)
                }
            }
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle("profileMgr.withdraw.view.title".i18nPZHelper)
    }

    // MARK: Private

    private static var isMiyousheInstalled: Bool {
        #if !canImport(UIKit)
        false
        #else
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
        #endif
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    private static var hoyolabStorePage: String {
        "https://apps.apple.com/app/hoyolab/id1559483982"
    }

    @State private var sheetHoyolabPresented: Bool = false
    @State private var sheetMiyoushePresented: Bool = false
}
