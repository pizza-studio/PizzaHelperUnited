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
        case .genshinImpact: colorSystemGray6.opacity(0.5)
        case .starRail: colorSysBackground.opacity(0.3).blendMode(.hardLight)
        }
    }

    var colorSystemGray6: Color {
        #if os(OSX)
        Color(nsColor: .systemGray).opacity(0.3333)
        #else
        Color(uiColor: .systemGray6)
        #endif
    }

    var colorSysBackground: Color {
        #if os(OSX)
        Color(nsColor: .textBackgroundColor).opacity(0.3333)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }

    var rawImage: Image {
        let guarded = guardedWallpaper
        return forLiveActivity ? guarded.image4LiveActivity : guarded.image4CellphoneWallpaper
    }

    var guardedWallpaper: Wallpaper {
        wallpaperOverride ?? wallpaper
    }

    // MARK: Private

    @Default(.background4App) private var wallpaper: Wallpaper
    @Environment(\.colorScheme) private var colorScheme
}
