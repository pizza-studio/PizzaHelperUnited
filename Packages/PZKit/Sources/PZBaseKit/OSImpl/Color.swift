// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

#if !canImport(UIKit) && canImport(AppKit)
import AppKit
public typealias UIColor = NSColor
#endif

extension UIColor {
    func modified(
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

extension Color {
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

    @ViewBuilder
    public static func accessibilityAccent(_ scheme: ColorScheme? = nil) -> Color {
        Color.primary.opacity(scheme == .dark ? 0.9 : 0.7)
    }
}
