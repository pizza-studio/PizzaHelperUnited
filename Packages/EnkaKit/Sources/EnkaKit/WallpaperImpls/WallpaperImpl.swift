// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WallpaperKit

// MARK: - NavigationBackground

extension View {
    @ViewBuilder
    public func listContainerBackground(wallpaperOverride: Wallpaper? = nil) -> some View {
        background(alignment: .topTrailing) {
            AppWallpaperView(forLiveActivity: false, blur: true)
        }
    }
}
