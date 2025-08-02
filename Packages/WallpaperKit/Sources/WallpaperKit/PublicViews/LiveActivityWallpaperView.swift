// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(iOS 15.0, macCatalyst 15.0, *)
extension BundledWallpaper {
    public var image4LiveActivity: Image {
        Image(assetName4LiveActivity, bundle: .module)
    }
}

// MARK: - LiveActivityWallpaperView

@available(iOS 16.2, macCatalyst 16.2, *)
public struct LiveActivityWallpaperView: View {
    // MARK: Lifecycle

    public init(game: Pizza.SupportedGame? = nil, wpIDOverride: Set<String> = []) {
        self.game = game
        self.wpIDOverride = wpIDOverride.isEmpty ? nil : wpIDOverride
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

    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var folderMonitor = UserWallpaperFileHandler.folderMonitor
    @State private var wpIDOverride: Set<String>?

    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>

    private let game: Pizza.SupportedGame?

    private var wpIDs: Binding<Set<String>> {
        .init {
            wpIDOverride ?? liveActivityWallpaperIDs
        } set: { newValue in
            if wpIDOverride != nil {
                wpIDOverride = newValue
            } else {
                liveActivityWallpaperIDs = newValue
            }
        }
    }

    private var viewRefreshHash: Int {
        Set(
            [
                broadcaster.eventForUserWallpaperDidSave.hashValue,
                wpIDs.wrappedValue.hashValue,
                folderMonitor.stateHash.hashValue,
            ]
        ).hashValue
    }

    private var labvParsed: LiveActivityBackgroundValueParsed { .init(wpIDs.wrappedValue) }

    private var currentSettings: BackgroundSettings {
        if labvParsed.useEmptyBackground { return .noBackground }
        let ids = wpIDs.wrappedValue
        var idsToRemove: Set<String> = []
        let mapped: [Wallpaper] = ids.compactMap { idStr in
            Wallpaper(id: idStr) {
                idsToRemove.insert(idStr)
            }
        }
        if !idsToRemove.isEmpty {
            wpIDs.wrappedValue = ids.subtracting(idsToRemove)
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

    private func getCachedOnlineBundledImageAsset(_ bundledWallpaper: BundledWallpaper) -> Image? {
        guard let url = bundledWallpaper.onlineAssetURL else { return nil }
        guard let cgImage = OnlineImageFS.getCGImageFromFS(url.absoluteString.md5) else { return nil }
        return Image(decorative: cgImage, scale: 1)
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
