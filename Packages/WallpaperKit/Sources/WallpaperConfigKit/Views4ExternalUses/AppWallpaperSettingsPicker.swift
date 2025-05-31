// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - AppWallpaperSettingsPicker

#if !os(watchOS)
public struct AppWallpaperSettingsPicker: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        Picker("settings.display.appBackground".i18nWPConfKit, selection: $background4App) {
            ForEach(Wallpaper.allCases) { wallpaper in
                Label {
                    Text(wallpaperName(for: wallpaper))
                } icon: {
                    GeometryReader { g in
                        wallpaper.image4LiveActivity
                            .resizable()
                            .scaledToFill()
                            .offset(x: -g.size.width)
                    }
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)
                }.tag(wallpaper)
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        .pickerStyle(.navigationLink)
        #endif
    }

    // MARK: Internal

    @Default(.useRealCharacterNames) var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) var customizedNameForWanderer: String

    // MARK: Private

    @Default(.background4App) private var background4App: Wallpaper

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
#endif
