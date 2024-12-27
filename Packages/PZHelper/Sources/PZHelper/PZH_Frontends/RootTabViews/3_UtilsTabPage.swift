// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AbyssRankKit
import GachaKit
import PZAccountKit
import PZBaseKit
import PZDictionaryKit
import SwiftUI
import WallpaperKit

struct UtilsTabPage: View {
    // MARK: Internal

    enum Nav {
        case giAbyssRank
        case gachaManager
        case wallpaperGallery
        case pizzaDictionary
        case hoyoMap
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                Section {
                    NavigationLink(value: Nav.gachaManager) {
                        Label {
                            Text(GachaRootView.navTitle)
                        } icon: {
                            GachaRootView.navIcon.resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                    NavigationLink(value: Nav.giAbyssRank) {
                        Label {
                            Text(AbyssRankView.navTitle)
                        } icon: {
                            AbyssRankView.navIcon.resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                }

                Section {
                    NavigationLink(value: Nav.wallpaperGallery) {
                        Label(WallpaperGalleryViewContent.navTitle, systemSymbol: .photoOnRectangleAngled)
                    }
                    NavigationLink(value: Nav.pizzaDictionary) {
                        Label(PZDictionaryView.navTitle, systemSymbol: .characterBookClosedFill)
                    }
                }
                Section {
                    NavigationLink(value: Nav.hoyoMap) {
                        Text(verbatim: HoYoMapView.navTitle)
                    }
                }
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
            case .giAbyssRank: AbyssRankView()
            case .gachaManager: GachaRootView()
            case .wallpaperGallery: WallpaperGalleryViewContent()
            case .pizzaDictionary: PZDictionaryView()
            case .hoyoMap: HoYoMapView()
            case .none: EmptyView() // Temporary for now.
            }
        }
    }
}
