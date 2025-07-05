// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - NavigationBackground

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
@available(watchOS 10.0, *)
extension View {
    @ViewBuilder
    public func listContainerBackground(
        wallpaperOverride: BundledWallpaper? = nil,
        thickMaterial: Bool = false
    )
        -> some View {
        background(alignment: .topTrailing) {
            #if !os(watchOS)
            AppWallpaperView()
                .saturation(thickMaterial ? 0.8 : 1)
                .overlay {
                    if thickMaterial {
                        Color.primary.colorInvert().opacity(0.1)
                    }
                }
            #endif
        }
    }
}

@available(iOS 15.0, *)
@available(macCatalyst 15.0, *)
@available(macOS 12.0, *)
@available(watchOS 8.0, *)
extension String {
    public var i18nWPKit: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

@available(iOS 15.0, *)
@available(macCatalyst 15.0, *)
@available(macOS 12.0, *)
@available(watchOS 8.0, *)
extension String.LocalizationValue {
    public var i18nWPKit: String {
        String(localized: self, bundle: .module)
    }
}
