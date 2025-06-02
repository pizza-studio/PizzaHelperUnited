// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - NavigationBackground

extension View {
    @ViewBuilder
    public func listContainerBackground(wallpaperOverride: Wallpaper? = nil) -> some View {
        background(alignment: .topTrailing) {
            #if !os(watchOS)
            AppWallpaperView()
            #endif
        }
    }
}

extension String {
    public var i18nWPKit: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

extension String.LocalizationValue {
    public var i18nWPKit: String {
        String(localized: self, bundle: .module)
    }
}
