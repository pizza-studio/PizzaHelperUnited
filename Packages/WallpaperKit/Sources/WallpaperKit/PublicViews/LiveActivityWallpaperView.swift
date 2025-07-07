// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
extension BundledWallpaper {
    public var image4LiveActivity: Image {
        Image(assetName4LiveActivity, bundle: .module)
    }
}

// MARK: - LiveActivityWallpaperView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct LiveActivityWallpaperView: View {
    // MARK: Lifecycle

    public init(game: Pizza.SupportedGame? = nil) {
        self.game = game
    }

    // MARK: Public

    public enum BackgroundSettings: AbleToCodeSendHash, Equatable {
        case noBackground
        case multiple(Set<Wallpaper>)
    }

    public var body: some View {
        ZStack {
            switch currentSettings {
            case .noBackground: EmptyView()
            case let .multiple(wallpapers):
                let finalWallpaper = getRandomWallpaper(wallpapers)
                let image = getRawImage(finalWallpaper)
                image
                    .resizable()
                    .scaledToFill()
                Color.black
                    .opacity(0.3)
            }
        }
        .compositingGroup()
        .id(viewRefreshHash)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    @State private var broadcaster = Broadcaster.shared
    @State private var folderMonitor = UserWallpaperFileHandler.folderMonitor

    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>

    private let game: Pizza.SupportedGame?

    private var viewRefreshHash: Int {
        Set(
            [
                broadcaster.eventForUserWallpaperDidSave.hashValue,
                liveActivityWallpaperIDs.hashValue,
                folderMonitor.stateHash.hashValue,
            ]
        ).hashValue
    }

    private var currentSettings: BackgroundSettings {
        let ids = liveActivityWallpaperIDs
        if ids.contains(Wallpaper.nullLiveActivityWallpaperIdentifier) { return .noBackground }
        var idsToRemove: Set<String> = []
        let mapped: [Wallpaper] = ids.compactMap { idStr in
            Wallpaper(id: idStr) {
                idsToRemove.insert(idStr)
            }
        }
        defer {
            liveActivityWallpaperIDs = ids.subtracting(idsToRemove)
        }
        return .multiple(.init(mapped))
    }

    private func getRandomWallpaper(_ rawSet: Set<Wallpaper>) -> Wallpaper {
        var wallpapersReturnable = rawSet
        if rawSet.isEmpty {
            wallpapersReturnable = .init(Wallpaper.allCases)
        }
        if rawSet.isEmpty, let game {
            wallpapersReturnable = wallpapersReturnable.filter { currentWallpaper in
                switch currentWallpaper {
                case .user: return true
                case let .bundled(bundledOne): return bundledOne.game == game
                }
            }
        }
        return wallpapersReturnable.randomElement() ?? .bundled(BundledWallpaper.defaultValue(for: game))
    }

    private func getRawImage(_ targetWallpaper: Wallpaper) -> Image {
        switch targetWallpaper {
        case let .bundled(bundledWallpaper):
            bundledWallpaper.image4LiveActivity
        case let .user(userWallpaper):
            if let cgImage = userWallpaper.imageHorizontal {
                Image(decorative: cgImage, scale: 1, orientation: .up)
            } else {
                Image(systemSymbol: .trashSlashSquare)
            }
        }
    }
}
