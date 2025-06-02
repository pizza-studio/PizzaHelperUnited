// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - LiveActivityUserWallpaperPicker

#if !os(watchOS)
public struct LiveActivityUserWallpaperPicker: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "settings.resinTimer.userWallpaper.navTitle"
        return .init(localized: key, bundle: .module)
    }()

    public static let navTitleForChoose: String = {
        let key: String.LocalizationValue = "settings.resinTimer.userWallpaper.navTitle.choose"
        return .init(localized: key, bundle: .module)
    }()

    public static let navDescription: String = {
        let key: String.LocalizationValue = "settings.resinTimer.userWallpaper.navDescription"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        NavigationStack {
            Form {
                ForEach(searchResults) { wallpaper in
                    let isThisOneChosen = userWallpaperIDs4LiveActivity.contains(wallpaper.id.uuidString)
                    Button {
                        if isThisOneChosen {
                            userWallpaperIDs4LiveActivity.remove(wallpaper.id.uuidString)
                        } else {
                            userWallpaperIDs4LiveActivity.insert(wallpaper.id.uuidString)
                        }
                    } label: {
                        drawUserWallpaperLabel(wallpaper, isChosen: isThisOneChosen)
                            .tag(wallpaper)
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

    var searchResults: [UserWallpaper] {
        if searchText.isEmpty {
            allUserWallpapersSorted
        } else {
            allUserWallpapersSorted.filter { wallpaper in
                wallpaper.name.lowercased().contains(searchText.lowercased())
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
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: 48).padding(.trailing, 4)
            VStack(alignment: .leading, spacing: 3) {
                Text(wallpaper.name)
                    .foregroundColor(isChosen ? .accentColor : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(wallpaper.dateString).fontDesign(.monospaced)
                }
                .font(.caption2)
                .fontWidth(.condensed)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
    @StateObject private var orientation = DeviceOrientation()
    @State private var searchText = ""
    @State private var containerSize: CGSize = .zero

    @Default(.userWallpapers4LiveActivity) private var userWallpaperIDs4LiveActivity: Set<String>

    private var userWallpapers4LiveActivity: Set<UserWallpaper> {
        .init(defaultsValueIDs: userWallpaperIDs4LiveActivity)
    }

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .navigationBarDrawer(displayMode: .always)
        #else
        return .automatic
        #endif
    }

    private var allUserWallpapersSorted: [UserWallpaper] {
        Defaults[.userWallpapers].sorted {
            $0.timestamp > $1.timestamp
        }
    }
}

#if DEBUG
#Preview {
    LiveActivityUserWallpaperPicker()
}
#endif
#endif
