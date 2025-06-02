// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - LiveActivityBackgroundPicker

#if !os(watchOS)
public struct LiveActivityBackgroundPicker: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "settings.resinTimer.background.navTitle"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        NavigationStack {
            Form {
                ForEach(searchResults) { wallpaper in
                    let isThisOneChosen = backgrounds4LiveActivity.contains(wallpaper)
                    Button {
                        if isThisOneChosen {
                            backgrounds4LiveActivity.remove(wallpaper)
                        } else {
                            backgrounds4LiveActivity.insert(wallpaper)
                        }
                    } label: {
                        Label {
                            HStack {
                                Text(wallpaperName(for: wallpaper))
                                    .foregroundColor(isThisOneChosen ? .accentColor : .primary)
                                    .fontWidth(.condensed)
                                Spacer()
                                if isThisOneChosen {
                                    Text(verbatim: "✔︎")
                                        .foregroundColor(.accentColor)
                                        .padding(.horizontal)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipShape(.rect)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipShape(.rect)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .searchable(text: $searchText, placement: searchFieldPlacement)
            .formStyle(.grouped)
            .navBarTitleDisplayMode(.inline) // 特例：這個畫面用 inline 會有更好的效能。
            .navigationTitle(Self.navTitle)
        }
    }

    // MARK: Internal

    var searchResults: [Wallpaper] {
        if searchText.isEmpty {
            Wallpaper.allCases
        } else {
            Wallpaper.allCases.filter { wallpaper in
                wallpaperName(for: wallpaper).lowercased().contains(searchText.lowercased())
            }
        }
    }

    // MARK: Private

    @Namespace private var animation
    @StateObject private var orientation = DeviceOrientation()
    @State private var searchText = ""
    @State private var containerSize: CGSize = .zero

    @Default(.backgrounds4LiveActivity) private var backgrounds4LiveActivity: Set<Wallpaper>
    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
    @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .navigationBarDrawer(displayMode: .always)
        #else
        return .automatic
        #endif
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
    LiveActivityBackgroundPicker()
}
#endif
#endif
