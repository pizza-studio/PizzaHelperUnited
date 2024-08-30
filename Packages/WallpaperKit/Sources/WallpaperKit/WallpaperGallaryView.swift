// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

// MARK: - WallpaperGalleryViewContent

public struct WallpaperGalleryViewContent: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "wallpaperGallery.navTitle".i18nWPKit

    @MainActor public var body: some View {
        GeometryReader { geometry in
            coreBodyView.onAppear {
                containerSize = geometry.size
            }.onChange(of: geometry.size) { _, newSize in
                containerSize = newSize
            }
        }
        .toolbar {
            #if os(macOS)
            let placement: ToolbarItemPlacement = .automatic
            #else
            let placement: ToolbarItemPlacement = .topBarTrailing
            #endif
            ToolbarItem(placement: placement) {
                Picker("".description, selection: $game.animation()) {
                    Text("game.genshin.shortNameEX".i18nBaseKit)
                        .tag(Pizza.SupportedGame.genshinImpact)
                    Text("game.starRail.shortNameEX".i18nBaseKit)
                        .tag(Pizza.SupportedGame.starRail)
                    Text("game.zenlessZone.shortNameEX".i18nBaseKit)
                        .tag(Pizza.SupportedGame.zenlessZone)
                }
                .padding(4)
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle(Self.navTitle)
    }

    // MARK: Internal

    var columns: Int {
        max(Int(floor($containerSize.wrappedValue.width / 240)), 1)
    }

    @ViewBuilder var coreBodyView: some View {
        StaggeredGrid(columns: columns, list: searchResults, content: { currentCard in
            draw(wallpaper: currentCard)
                .matchedGeometryEffect(id: currentCard.id, in: animation)
        })
        .searchable(text: $searchText)
        .padding(.horizontal)
        .animation(.easeInOut, value: columns)
        .environment(orientation)
    }

    var searchResults: [Wallpaper] {
        if searchText.isEmpty {
            return Wallpaper.allCases(for: game)
        } else {
            return Wallpaper.allCases(for: game).filter { wallpaper in
                wallpaperName(for: wallpaper).lowercased().contains(searchText.lowercased())
            }
        }
    }

    // MARK: Private

    @Namespace private var animation
    @State private var orientation = DeviceOrientation()
    @State private var game: Pizza.SupportedGame = appGame ?? .genshinImpact
    @State private var searchText = ""
    @State private var containerSize: CGSize = .zero
    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String

    private func wallpaperName(for wallpaper: Wallpaper) -> String {
        var result = useRealCharacterNames ? wallpaper.localizedRealName : wallpaper.localizedName
        checkKunikuzushi: if wallpaper.id == "210143" {
            guard !customizedNameForWanderer.isEmpty, !useRealCharacterNames else {
                break checkKunikuzushi
            }
            let separators: [String] = [" – ", ": ", " - ", "·"]
            checkSeparator: for separator in separators {
                guard result.contains(separator) else { continue }
                result = result.split(separator: separator).dropFirst().joined()
                result = customizedNameForWanderer + separator + result
                break checkSeparator
            }
        }
        if forceCharacterWeaponNameFixed {
            if Locale.isUILanguageSimplifiedChinese {
                if wallpaper.id == "210044" {
                    return result.replacingOccurrences(of: "钟离", with: "锺离")
                }
            } else if Locale.isUILanguageTraditionalChinese {
                if wallpaper.id == "210108" {
                    return result.replacingOccurrences(of: "堇", with: "菫")
                }
            }
        }
        return result
    }

    @MainActor @ViewBuilder
    private func draw(wallpaper: Wallpaper) -> some View {
        wallpaper.image4LiveActivity
            .resizable()
            .scaleEffect(1.01) // HSR 的名片有光边。
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .corneredTag(
                verbatim: wallpaperName(for: wallpaper),
                alignment: .bottomLeading,
                opacity: 0.9,
                padding: 6
            )
    }
}

#if DEBUG
#Preview {
    WallpaperGalleryViewContent()
}
#endif
