// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperConfigKit

@available(iOS 17.0, macCatalyst 17.0, *)
struct UtilsTabPage: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                ASUpdateNoticeView()
                    .font(.footnote)
                Section {
                    NavigationLink(destination: GachaRootView.init) {
                        Label {
                            Text(GachaRootView.navTitle)
                        } icon: {
                            GachaRootView.navIcon.resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                } footer: {
                    Text(GachaRootView.navDescription)
                }

                Section {
                    NavigationLink(destination: WallpaperGalleryViewContent.init) {
                        Label(WallpaperGalleryViewContent.navTitle, systemSymbol: .photoOnRectangleAngled)
                    }
                    NavigationLink(destination: UserWallpaperMgrViewContent.init) {
                        Label(UserWallpaperMgrViewContent.navTitle, systemSymbol: .photoFillOnRectangleFill)
                    }
                } footer: {
                    Text(UserWallpaperMgrViewContent.navDescription)
                }
                HoYoMapMenuLinkSection()
                Text("tab.utils.featureRemovalNotice", bundle: .module)
                    .asInlineTextDescription()
            }
            .formStyle(.grouped)
            .navigationTitle("tab.utils.fullTitle".i18nPZHelper)
            .navBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom, content: rootNavVM.iOSBottomTabBarForBuggyOS25ReleasesOn)
        }
    }

    // MARK: Private

    @State private var rootNavVM = RootNavVM.shared
}
