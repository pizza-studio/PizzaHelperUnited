// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

#if !canImport(UIKit) && canImport(AppKit)
import AppKit
public typealias UIColor = NSColor
#endif

extension UIColor {
    public func modified(
        withAdditionalHue hue: CGFloat,
        additionalSaturation: CGFloat,
        additionalBrightness: CGFloat
    )
        -> UIColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        #if !canImport(UIKit) && canImport(AppKit)
        getHue(
            &currentHue,
            saturation: &currentSaturation,
            brightness: &currentBrigthness,
            alpha: &currentAlpha
        )
        return UIColor(
            hue: currentHue + hue,
            saturation: currentSaturation + additionalSaturation,
            brightness: currentBrigthness + additionalBrightness,
            alpha: currentAlpha
        )
        #else
        if getHue(
            &currentHue,
            saturation: &currentSaturation,
            brightness: &currentBrigthness,
            alpha: &currentAlpha
        ) {
            return UIColor(
                hue: currentHue + hue,
                saturation: currentSaturation + additionalSaturation,
                brightness: currentBrigthness + additionalBrightness,
                alpha: currentAlpha
            )
        } else {
            return self
        }
        #endif
    }
}

#if !canImport(UIKit) && canImport(AppKit)
extension UIColor {
    public static var secondarySystemBackground: UIColor { .windowBackgroundColor }
    public static var systemBackground: UIColor { .controlBackgroundColor }
}
#endif

extension Color {
    public static var colorSystemGray6: Color {
        #if os(OSX)
        Color(nsColor: .systemGray).opacity(0.3333)
        #else
        Color(uiColor: .systemGray6)
        #endif
    }

    public static var colorSysBackground: Color {
        #if os(OSX)
        Color(nsColor: .textBackgroundColor).opacity(0.3333)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }

    public func addSaturation(_ added: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.modified(
            withAdditionalHue: 0,
            additionalSaturation: added,
            additionalBrightness: 0
        ))
    }

    public func addBrightness(_ added: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.modified(
            withAdditionalHue: 0,
            additionalSaturation: 0,
            additionalBrightness: added
        ))
    }

    @MainActor @ViewBuilder
    public static func accessibilityAccent(_ scheme: ColorScheme? = nil) -> Color {
        Color.primary.opacity(scheme == .dark ? 0.9 : 0.7)
    }
}
