// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import SwiftUI

// MARK: - WidgetLegibilityShadowModifier

private struct WidgetLegibilityShadowModifier: ViewModifier {
    let isText: Bool
    @Default(.widgetContentLegibilityShadowOpacity) var widgetContentLegibilityShadowOpacity: Double

    var opacity: CGFloat {
        widgetContentLegibilityShadowOpacity * (isText ? 1 : 0.7)
    }

    func body(content: Content) -> some View {
        content
            .shadow(
                color: .black.opacity(opacity),
                radius: 2,
                x: 0,
                y: 0
            )
    }
}

extension View {
    func widgetLegibilityShadow(isText: Bool = true) -> some View {
        modifier(WidgetLegibilityShadowModifier(isText: isText))
    }
}
