// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI

extension BundledWallpaper {
    public var image4CellphoneWallpaper: Image {
        Image(assetName, bundle: .module)
    }
}

// MARK: - AppWallpaperView

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
public struct AppWallpaperView: View {
    // MARK: Lifecycle

    public init(blur: Bool = true) {
        self.blur = blur
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }

    // MARK: Public

    public var body: some View {
        rawImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .scaleEffect(blur ? 1.2 : 0)
            .blur(radius: blur ? blurAmount : 0)
            .saturation(blur ? 1.5 : 1)
            .overlay {
                if blur {
                    overlayContent4Blur
                }
            }
            .ignoresSafeArea(.all)
            .compositingGroup()
            .id(viewRefreshHash)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    @State private var broadcaster = Broadcaster.shared
    @State private var folderMonitor = UserWallpaperFileHandler.folderMonitor

    @Default(.appWallpaperID) private var appWallpaperID: String

    private let blur: Bool

    private var viewRefreshHash: Int {
        Set(
            [
                broadcaster.eventForUserWallpaperDidSave.hashValue,
                appWallpaperID.hashValue,
                folderMonitor.stateHash.hashValue,
            ]
        ).hashValue
    }

    private var isUserWallpaperEnabled: Bool {
        userWallpaperUUID != nil
    }

    private var userWallpaperUUID: UUID? {
        UUID(uuidString: appWallpaperID)
    }

    private var currentWallpaper: Wallpaper {
        .init(id: appWallpaperID) {
            Defaults.reset(.appWallpaperID)
        } ?? .finalFallbackValue
    }

    private var blurAmount: CGFloat {
        switch currentWallpaper.game {
        case .genshinImpact: 30
        case .starRail: 50
        case .zenlessZone: 50
        case .none: 50
        }
    }

    private var rawImage: Image {
        switch currentWallpaper {
        case let .bundled(bundledWallpaper):
            bundledWallpaper.image4CellphoneWallpaper
        case let .user(userWallpaper):
            if let cgImage = userWallpaper.imageSquared {
                Image(decorative: cgImage, scale: 1, orientation: .up)
            } else {
                Image(systemSymbol: .trashSlashSquare)
            }
        }
    }

    @ViewBuilder private var overlayContent4Blur: some View {
        switch currentWallpaper {
        case let .bundled(bundledWallpaper):
            switch bundledWallpaper.game {
            case .genshinImpact: Color.colorSystemGray6.opacity(0.5)
            case .starRail: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            case .zenlessZone: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            case .none: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            }
        case .user:
            Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
        }
    }
}

#endif
