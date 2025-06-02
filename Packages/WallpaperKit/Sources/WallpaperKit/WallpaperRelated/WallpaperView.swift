// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

extension Wallpaper {
    public var image4LiveActivity: Image {
        Image(assetName4LiveActivity, bundle: .module)
    }

    public var image4CellphoneWallpaper: Image {
        Image(assetName, bundle: .module)
    }
}

// MARK: - AppWallpaperView

#if !os(watchOS)
public struct AppWallpaperView: View {
    // MARK: Lifecycle

    public init(blur: Bool = true) {
        self.blur = blur
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
    }

    // MARK: Internal

    @State var blur: Bool

    var blurAmount: CGFloat {
        switch wallpaper.game {
        case .genshinImpact: 30
        case .starRail: 50
        case .zenlessZone: 50
        case .none: 50
        }
    }

    var rawImage: Image {
        userWallpaperOverride ?? wallpaper.image4CellphoneWallpaper
    }

    var userWallpaperOverride: Image? {
        let cgImage = UserWallpaper(defaultsValueID: userWallpaperID)?.imageSquared
        guard let cgImage else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }

    @ViewBuilder var overlayContent4Blur: some View {
        if userWallpaperOverride != nil {
            Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
        } else {
            switch wallpaper.game {
            case .genshinImpact: Color.colorSystemGray6.opacity(0.5)
            case .starRail: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            case .zenlessZone: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            case .none: Color.colorSysBackground.opacity(0.3).blendMode(.hardLight)
            }
        }
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    @Default(.background4App) private var wallpaper: Wallpaper
    @Default(.userWallpaper4App) private var userWallpaperID: String?
}
#endif
