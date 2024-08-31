// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import SwiftUI
import WallpaperKit

struct UtilsTabPage: View {
    // MARK: Internal

    enum Nav {
        case wallpaperGallery
        case gachaCloudDebug
    }

    @MainActor var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                NavigationLink(value: Nav.wallpaperGallery) {
                    Label(WallpaperGalleryViewContent.navTitle, systemSymbol: .photoOnRectangleAngled)
                }
                #if DEBUG
                NavigationLink(value: Nav.gachaCloudDebug) {
                    Label("# Gacha Cloud Debug".i18nPZHelper, systemSymbol: .cloudFogFill)
                }
                #endif
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
            case .wallpaperGallery: WallpaperGalleryViewContent()
            case .gachaCloudDebug: GachaMODebugView()
            case .none: GachaMODebugView()
            }
        }
    }
}
