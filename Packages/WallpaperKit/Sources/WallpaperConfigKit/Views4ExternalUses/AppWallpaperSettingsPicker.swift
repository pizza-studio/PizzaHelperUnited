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

    public static let navSectionHeader: String = {
        let key: String.LocalizationValue = "settings.display.appWallpaper.navSectionHeader"
        return .init(localized: key, bundle: .module)
    }()

    public static let navDescription: String = {
        let key: String.LocalizationValue = "settings.display.appWallpaper.navDescription"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        Picker("settings.display.appBackground".i18nWPConfKit, selection: $appWallpaperID) {
            ForEach(Wallpaper.allCases) { currentWallpaper in
                let isChosen = currentWallpaper.id == appWallpaperID
                switch currentWallpaper {
                case let .bundled(wallpaper):
                    drawBundledWallpaperLabel(wallpaper, isChosen: isChosen)
                        .tag(currentWallpaper.id)
                case let .user(userWallpaper):
                    drawUserWallpaperLabel(userWallpaper, isChosen: isChosen)
                        .tag(currentWallpaper.id)
                }
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        .pickerStyle(.navigationLink)
        #endif
    }

    // MARK: Internal

    @ViewBuilder
    func drawUserWallpaperLabel(_ wallpaper: UserWallpaper?, isChosen: Bool) -> some View {
        let cgImage = wallpaper?.imageSquared
        let iconImage: Image = {
            if let cgImage { return Image(decorative: cgImage, scale: 1, orientation: .up) }
            return Image(systemSymbol: .trashSlashFill)
        }()
        /// LabeledContent 与 iPadOS 18 的某些版本不相容，使得此处需要改用 HStack 应对处理。
        HStack {
            iconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 32, height: 32).padding(.trailing, 4)
            if let wallpaperName = wallpaper?.name {
                Text(wallpaperName)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isChosen ? .accentColor : .primary)
            } else {
                Text(
                    "settings.display.appWallpaper.userWallPaper.notSpecified",
                    bundle: .module
                )
                .multilineTextAlignment(.leading)
                .foregroundColor(isChosen ? .accentColor : .primary)
            }
        }
    }

    @ViewBuilder
    func drawBundledWallpaperLabel(_ wallpaper: BundledWallpaper, isChosen: Bool) -> some View {
        /// LabeledContent 与 iPadOS 18 的某些版本不相容，使得此处需要改用 HStack 应对处理。
        HStack {
            GeometryReader { g in
                wallpaper.image4LiveActivity
                    .resizable()
                    .scaledToFill()
                    .offset(x: -g.size.width)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .frame(width: 32, height: 32).padding(.trailing, 4)
            Text(wallpaperName(for: wallpaper))
                .multilineTextAlignment(.leading)
                .foregroundColor(isChosen ? .accentColor : .primary)
        }
    }

    // MARK: Private

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String
    @Default(.appWallpaperID) private var appWallpaperID: String

    private func wallpaperName(for wallpaper: BundledWallpaper) -> String {
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
