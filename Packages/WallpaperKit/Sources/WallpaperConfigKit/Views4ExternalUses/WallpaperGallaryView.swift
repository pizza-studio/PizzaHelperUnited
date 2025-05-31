// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit

// MARK: - WallpaperGalleryViewContent

#if !os(watchOS)
public struct WallpaperGalleryViewContent: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "wallpaperGallery.navTitle".i18nWPConfKit

    public var body: some View {
        coreBodyView
            .containerRelativeFrame(.horizontal) { length, _ in
                Task { @MainActor in
                    withAnimation { containerWidth = length - 48 }
                }
                return length
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Picker("".description, selection: $game.animation()) {
                        Text("game.genshin.shortNameEX".i18nBaseKit)
                            .tag(Pizza.SupportedGame.genshinImpact as Pizza.SupportedGame?)
                        Text("game.starRail.shortNameEX".i18nBaseKit)
                            .tag(Pizza.SupportedGame.starRail as Pizza.SupportedGame?)
                        Text("game.zenlessZone.shortNameEX".i18nBaseKit)
                            .tag(Pizza.SupportedGame.zenlessZone as Pizza.SupportedGame?)
                        Text("wpKit.gamePicker.Pizza.shortName".i18nWPConfKit)
                            .tag(Pizza.SupportedGame?.none)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(Self.navTitle)
    }

    // MARK: Internal

    var columns: Int {
        max(Int(floor(containerWidth / 240)), 1)
    }

    var searchResults: [Wallpaper] {
        if searchText.isEmpty {
            Wallpaper.allCases(for: game)
        } else {
            Wallpaper.allCases(for: game).filter { wallpaper in
                wallpaperName(for: wallpaper).lowercased().contains(searchText.lowercased())
            }
        }
    }

    @ViewBuilder var coreBodyView: some View {
        StaggeredGrid(
            columns: columns,
            showsIndicators: true,
            list: searchResults
        ) { currentCard in
            draw(wallpaper: currentCard)
                .matchedGeometryEffect(id: currentCard.id, in: animation)
                .contextMenu {
                    Button("wpKit.assign.background4App".i18nWPConfKit) {
                        background4App = currentCard
                    }
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                    let alreadyChosenAsLABG: Bool = liveActivityUseCustomizeBackground
                        && !liveActivityUseEmptyBackground
                        && backgrounds4LiveActivity.contains(currentCard)
                    Button {
                        if alreadyChosenAsLABG {
                            backgrounds4LiveActivity.remove(currentCard)
                            if backgrounds4LiveActivity.isEmpty {
                                liveActivityUseEmptyBackground = true
                                liveActivityUseCustomizeBackground = false
                            }
                        } else {
                            liveActivityUseEmptyBackground = false
                            liveActivityUseCustomizeBackground = true
                            backgrounds4LiveActivity.insert(currentCard)
                        }
                    } label: {
                        Label(
                            "wpKit.assign.backgrounds4LiveActivity".i18nWPConfKit,
                            systemSymbol: alreadyChosenAsLABG ? nil : .checkmark
                        )
                    }
                    #endif
                }
        }
        .searchable(text: $searchText, placement: searchFieldPlacement)
        .padding(.horizontal)
        .animation(.easeInOut, value: columns)
        .environment(orientation)
    }

    // MARK: Private

    @Namespace private var animation
    @StateObject private var orientation = DeviceOrientation()
    @State private var game: Pizza.SupportedGame? = appGame ?? .genshinImpact
    @State private var searchText = ""
    @State private var containerWidth: CGFloat = 320

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String
    @Default(.background4App) private var background4App: Wallpaper
    @Default(.backgrounds4LiveActivity) private var backgrounds4LiveActivity: Set<Wallpaper>
    @Default(.resinRecoveryLiveActivityUseEmptyBackground) private var liveActivityUseEmptyBackground: Bool
    @Default(.resinRecoveryLiveActivityUseCustomizeBackground) private var liveActivityUseCustomizeBackground: Bool

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .navigationBarDrawer(displayMode: .always)
        #else
        return .automatic
        #endif
    }

    @ViewBuilder
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
}

#if DEBUG
#Preview {
    WallpaperGalleryViewContent()
}
#endif
#endif
