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
        case gachaCloudDebug
    }

    @MainActor var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            List(selection: $nav) {
                Section {
                    NavigationLink(value: Nav.giAbyssRank) {
                        Label {
                            Text(AbyssRankView.navTitle)
                        } icon: {
                            AbyssRankView.navIcon.resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                    NavigationLink(value: Nav.gachaManager) {
                        Label {
                            Text(GachaRecordRootView.navTitle)
                        } icon: {
                            GachaRecordRootView.navIcon.resizable().aspectRatio(contentMode: .fit)
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
                    Menu {
                        #if os(macOS) || targetEnvironment(macCatalyst)
                        Link(destination: "https://genshin.yunlu18.net".asURL) {
                            Text(verbatim: "Alice Workshop (\(Pizza.SupportedGame.genshinImpact.localizedShortName))")
                        }
                        Link(destination: "https://starrail.yunlu18.net/".asURL) {
                            Text(verbatim: "Alice Workshop (\(Pizza.SupportedGame.starRail.localizedShortName))")
                        }
                        #else
                        Link(destination: "https://apps.apple.com/app/id1620751192".asURL) {
                            Text(verbatim: "Alice Workshop (\(Pizza.SupportedGame.genshinImpact.localizedShortName))")
                        }
                        Link(destination: "https://apps.apple.com/app/id6450605570".asURL) {
                            Text(verbatim: "Alice Workshop (\(Pizza.SupportedGame.starRail.localizedShortName))")
                        }
                        #endif
                    } label: {
                        Text(verbatim: "Alice Workshop (App Store)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
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

    @MainActor @ViewBuilder
    private func navigationDetail(selection: Binding<Nav?>) -> some View {
        NavigationStack {
            switch selection.wrappedValue {
            case .giAbyssRank: AbyssRankView()
            case .gachaManager: GachaRecordRootView {
                    PersistenceController.command4InheritingOldGachaRecord()
                }
            case .wallpaperGallery: WallpaperGalleryViewContent()
            case .pizzaDictionary: PZDictionaryView()
            case .gachaCloudDebug: EmptyView() // CDGachaMODebugView()
            case .hoyoMap: HoYoMapView()
            case .none: EmptyView() // CDGachaMODebugView()
            }
        }
    }
}
