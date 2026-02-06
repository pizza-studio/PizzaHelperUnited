// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

extension BundledWallpaper {
    public var image4CellphoneWallpaper: Image {
        Image(assetName, bundle: .currentSPM)
    }
}

// MARK: - AppWallpaperView

#if !os(watchOS)
@available(iOS 16.0, macCatalyst 16.0, *)
public struct AppWallpaperView: View {
    // MARK: Lifecycle

    public init(blur: Bool = true, thickMaterial: Bool = false) {
        self.blur = blur
        self.thickMaterial = thickMaterial
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }

    // MARK: Public

    public var body: some View {
        Group {
            if blur {
                if let processedBlurredImage {
                    processedBlurredImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.2)
                        .saturation(totalSaturation)
                } else {
                    rawImageBlurred
                        .scaleEffect(1.2)
                        .saturation(totalSaturation)
                }
            } else {
                rawImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(0)
            }
        }
        .overlay {
            if blur {
                overlayContent4Blur
            }
        }
        .overlay {
            if thickMaterial {
                Color.primary.colorInvert().opacity(0.1)
            }
        }
        .drawingGroup()
        .ignoresSafeArea(.all)
        .id(viewRefreshHash)
        .task(id: appWallpaperID) {
            if blur {
                loadBlurredImage()
            }
        }
    }

    // MARK: Private

    private final class CacheCleaner {
        // MARK: Lifecycle

        deinit {
            if let key {
                Task { @MainActor [key] in
                    AppWallpaperView.wallpaperCache.removeValue(forKey: key)
                }
            }
        }

        // MARK: Internal

        var key: String?
    }

    private static var wallpaperCache = [String: Image]()

    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var folderMonitor = UserWallpaperFileHandler.folderMonitor
    @State private var processedBlurredImage: Image?
    @State private var cacheCleaner = CacheCleaner()

    @Default(.appWallpaperID) private var appWallpaperID: String

    private let blur: Bool
    private let thickMaterial: Bool

    private var totalSaturation: Double {
        (blur ? 1.5 : 1) * (thickMaterial ? 0.8 : 1)
    }

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

    private var blurAmount: Double {
        let initVal: Double = switch currentWallpaper.game {
        case .genshinImpact: 30
        case .starRail: 50
        case .zenlessZone: 50
        case .none: 50
        }
        return initVal * 0.3
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

    @ViewBuilder private var rawImageBlurred: some View {
        rawImage
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 400)
            .blur(radius: blurAmount)
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

    private func loadBlurredImage() {
        let cacheKey = "\(appWallpaperID)-\(blurAmount)"
        cacheCleaner.key = cacheKey
        if let cached = Self.wallpaperCache[cacheKey] {
            processedBlurredImage = cached
            return
        }

        let blurred = processImage(rawImage, targetHeight: 400, blurRadius: blurAmount)

        if let blurred {
            Self.wallpaperCache[cacheKey] = blurred
            processedBlurredImage = blurred
        }
    }

    private func processImage(_ image: Image, targetHeight: CGFloat, blurRadius: CGFloat) -> Image? {
        let renderer = ImageRenderer(content: rawImageBlurred)
        renderer.scale = 2
        guard let cgImage = renderer.cgImage else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

#endif
