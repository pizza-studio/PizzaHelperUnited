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

public struct AppWallpaperView: View {
    // MARK: Lifecycle

    public init(wallpaperOverride: Wallpaper? = nil, forLiveActivity: Bool = false, blur: Bool = false) {
        self.wallpaperOverride = wallpaperOverride
        self.forLiveActivity = forLiveActivity
        self.blur = blur
    }

    public init(charID4Genshin: String, blur: Bool = false) {
        self.wallpaperOverride = .findNameCardForGenshinCharacter(charID: charID4Genshin)
        self.forLiveActivity = false
        self.blur = blur
    }

    // MARK: Public

    public var body: some View {
        Group {
            switch guardedWallpaper.game {
            case .genshinImpact:
                rawImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(blur ? 1.2 : 0)
                    .ignoresSafeArea(.all)
                    .blur(radius: blur ? blurAmount : 1)
                    .saturation(blur ? 1.5 : 1)
                    .overlay(Color(UIColor.systemGray6).opacity(0.5))
            case .starRail:
                rawImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .scaleEffect(blur ? 1.2 : 0)
                    .blur(radius: blur ? blurAmount : 0)
                    .ignoresSafeArea(.all)
                    .saturation(blur ? 1.5 : 1)
                    .overlay {
                        if blur {
                            overlayContent4Blur
                        }
                    }
            }
        }
        .compositingGroup()
    }

    // MARK: Internal

    @State var wallpaperOverride: Wallpaper?
    @State var forLiveActivity: Bool
    @State var blur: Bool

    var blurAmount: CGFloat {
        switch guardedWallpaper.game {
        case .genshinImpact: 30
        case .starRail: 50
        }
    }

    @ViewBuilder var overlayContent4Blur: some View {
        switch guardedWallpaper.game {
        case .genshinImpact: Color(uiColor: .systemGray6).opacity(0.5)
        case .starRail: Color(uiColor: .systemBackground).opacity(0.3).blendMode(.hardLight)
        }
    }

    var rawImage: Image {
        let guarded = guardedWallpaper
        return forLiveActivity ? guarded.image4LiveActivity : guarded.image4CellphoneWallpaper
    }

    var guardedWallpaper: Wallpaper {
        wallpaperOverride ?? wallpaper ?? .randomValue(for: appGame ?? .genshinImpact)
    }

    // MARK: Private

    @Default(.background4App) private var wallpaper: Wallpaper?
}
