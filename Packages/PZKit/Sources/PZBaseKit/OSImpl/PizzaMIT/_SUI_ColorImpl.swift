// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

/// The only implementation of this file for SwiftUI.
@available(iOS 15.0, macCatalyst 15.0, *)
extension CGColor {
    public var suiColor: Color {
        .init(cgColor: self)
    }
}

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
        #else
        let isSucceeded: Bool = getHue(
            &currentHue,
            saturation: &currentSaturation,
            brightness: &currentBrigthness,
            alpha: &currentAlpha
        )
        guard isSucceeded else { return self }
        #endif

        return UIColor(
            hue: currentHue + hue,
            saturation: currentSaturation + additionalSaturation,
            brightness: currentBrigthness + additionalBrightness,
            alpha: currentAlpha
        )
    }
}

#if !canImport(UIKit) && canImport(AppKit)
extension UIColor {
    public static var secondarySystemBackground: UIColor { .windowBackgroundColor }
    public static var systemBackground: UIColor { .controlBackgroundColor }
}
#endif

@available(iOS 15.0, macCatalyst 15.0, *)
extension Color {
    #if !os(watchOS)
    public static var colorSystemGray6: Color {
        #if os(macOS)
        Color(nsColor: .systemGray).opacity(0.3333)
        #else
        Color(uiColor: .systemGray6)
        #endif
    }

    public static var colorSysBackground: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor).opacity(0.3333)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }
    #endif

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
