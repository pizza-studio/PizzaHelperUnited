// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - NavigationBackground

#if !os(watchOS)
extension View {
    @ViewBuilder
    public func listContainerBackground(
        wallpaperOverride: BundledWallpaper? = nil,
        thickMaterial: Bool = false
    )
        -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            background {
                AppWallpaperView()
                    .saturation(thickMaterial ? 0.8 : 1)
                    .overlay {
                        if thickMaterial {
                            Color.primary.colorInvert().opacity(0.1)
                        }
                    }
            }
        } else {
            self
        }
    }
}
#endif

@available(iOS 15.0, macCatalyst 15.0, *)
extension String {
    public var i18nWPKit: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }
}

@available(iOS 15.0, macCatalyst 15.0, *)
extension String.LocalizationValue {
    public var i18nWPKit: String {
        String(localized: self, bundle: .module)
    }
}
