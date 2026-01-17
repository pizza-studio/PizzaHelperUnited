// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

@available(iOS 15.0, macCatalyst 15.0, *)
extension BundledWallpaper {
    public var image4LiveActivity: Image {
        Image(assetName4LiveActivity, bundle: .currentSPM)
    }
}

// MARK: - LiveActivityWallpaperView

@available(iOS 16.2, macCatalyst 16.2, *)
public struct LiveActivityWallpaperView: View {
    // MARK: Lifecycle

    public init(wallpaperID: String?) {
        if let wallpaperID {
            self.wallpaper = Wallpaper(id: wallpaperID)
        } else {
            self.wallpaper = nil
        }
        self.game = wallpaper?.game
    }

    // MARK: Public

    public var body: some View {
        ZStack {
            switch wallpaper {
            case .none: EmptyView()
            case let .some(wpGuarded):
                let image = getRawImage(wpGuarded)
                image
                    .resizable()
                    .scaledToFill()
                Color.black
                    .opacity(0.3)
            }
        }
        .drawingGroup()
        .id(viewRefreshHash)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var folderMonitor = UserWallpaperFileHandler.folderMonitor

    private let game: Pizza.SupportedGame?
    private let wallpaper: Wallpaper?

    private var viewRefreshHash: Int {
        Set(
            [
                broadcaster.eventForUserWallpaperDidSave.hashValue,
                folderMonitor.stateHash.hashValue,
            ]
        ).hashValue
    }

    private func getCachedOnlineBundledImageAsset(_ bundledWallpaper: BundledWallpaper) -> Image? {
        guard let url = bundledWallpaper.onlineAssetURL else { return nil }
        return ImageMap.shared.assetMap[url]?.img
    }

    private func getRawImage(_ targetWallpaper: Wallpaper) -> Image {
        switch targetWallpaper {
        case let .bundled(bundledWallpaper):
            switch bundledWallpaper.game {
            case .genshinImpact:
                getCachedOnlineBundledImageAsset(bundledWallpaper)
                    ?? bundledWallpaper.image4LiveActivity
            default:
                bundledWallpaper.image4LiveActivity
            }
        case let .user(userWallpaper):
            if let cgImage = userWallpaper.imageHorizontal {
                Image(decorative: cgImage, scale: 1, orientation: .up)
            } else {
                Image(systemSymbol: .trashSlashSquare)
            }
        }
    }
}
