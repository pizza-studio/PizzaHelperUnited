// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - LiveActivityBackgroundPicker

@available(iOS 16.2, macCatalyst 16.2, *)
public struct LiveActivityBackgroundPicker: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "settings.staminaTimer.background.navTitle"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        NavigationStack {
            Form {
                ForEach(searchResults) { currentWallpaper in
                    let isChosen = liveActivityWallpaperIDs.contains(currentWallpaper.id)
                    Button {
                        if isChosen {
                            liveActivityWallpaperIDs.remove(currentWallpaper.id)
                        } else {
                            liveActivityWallpaperIDs.insert(currentWallpaper.id)
                        }
                    } label: {
                        switch currentWallpaper {
                        case let .bundled(wallpaper):
                            drawBundledWallpaperLabel(wallpaper, isChosen: isChosen)
                        case let .user(userWallpaper):
                            drawUserWallpaperLabel(userWallpaper, isChosen: isChosen)
                        }
                    }
                    .buttonStyle(.borderless)
                    .tag(currentWallpaper.id)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clipShape(.rect)
                }
            }
            .formStyle(.grouped).disableFocusable()
            .searchable(text: $searchText, placement: searchFieldPlacement)
            .navBarTitleDisplayMode(.inline) // 特例：這個畫面用 inline 會有更好的效能。
            .navigationTitle(Self.navTitle)
        }
    }

    // MARK: Internal

    var searchResults: [Wallpaper] {
        if searchText.isEmpty {
            Wallpaper.allCases
        } else {
            Wallpaper.allCases.filter { currentWallpaper in
                switch currentWallpaper {
                case let .user(userWallpaper):
                    userWallpaper.name.lowercased().contains(searchText.lowercased())
                case let .bundled(bundledWallpaper):
                    wallpaperName(for: bundledWallpaper).lowercased().contains(searchText.lowercased())
                }
            }
        }
    }

    @ViewBuilder
    func drawUserWallpaperLabel(_ wallpaper: UserWallpaper, isChosen: Bool) -> some View {
        let cgImage = wallpaper.imageSquared
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
            Text(wallpaper.name)
                .multilineTextAlignment(.leading)
                .foregroundColor(isChosen ? .accentColor : .primary)
            Spacer()
            if isChosen {
                Text(verbatim: "✔︎")
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)
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
            Spacer()
            if isChosen {
                Text(verbatim: "✔︎")
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: Private

    @Namespace private var animation
    @State private var searchText = ""
    @State private var containerSize: CGSize = .zero

    @Default(.useAlternativeCharacterNames) private var useAlternativeCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String
    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .navigationBarDrawer(displayMode: .always)
        #else
        return .automatic
        #endif
    }

    private func wallpaperName(for wallpaper: BundledWallpaper) -> String {
        var result = useAlternativeCharacterNames ? wallpaper.localizedRealName : wallpaper.localizedName
        checkKunikuzushi: if wallpaper.id == "210143" {
            guard !customizedNameForWanderer.isEmpty, !useAlternativeCharacterNames else {
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
@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    LiveActivityBackgroundPicker()
}
#endif
#endif
