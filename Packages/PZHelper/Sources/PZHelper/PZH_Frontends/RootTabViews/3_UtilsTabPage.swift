// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperKit

struct UtilsTabPage: View {
    // MARK: Internal

    enum Nav {
        case gachaManager
        case wallpaperGallery
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                ASUpdateNoticeView()
                    .font(.footnote)
                Section {
                    NavigationLink(value: Nav.gachaManager) {
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
                    NavigationLink(value: Nav.wallpaperGallery) {
                        Label(WallpaperGalleryViewContent.navTitle, systemSymbol: .photoOnRectangleAngled)
                    }
                }
                HoYoMapMenuLinkSection()
                Text("tab.utils.featureRemovalNotice", bundle: .module)
                    .asInlineTextDescription()
            }
            #if os(iOS) || targetEnvironment(macCatalyst)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.bordered)
            #endif
            .navigationTitle("tab.utils.fullTitle".i18nPZHelper)
        } detail: {
            navigationDetail(selection: $nav)
        }
    }

    // MARK: Private

    @State private var nav: Nav?

    @ViewBuilder
    private func navigationDetail(selection: Binding<Nav?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .gachaManager: GachaRootView()
            case .wallpaperGallery: WallpaperGalleryViewContent()
            case .none: EmptyView() // Temporary for now.
            }
        }
    }
}
