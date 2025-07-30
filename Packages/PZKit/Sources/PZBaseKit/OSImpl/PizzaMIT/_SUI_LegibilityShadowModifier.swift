// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Defaults
import SwiftUI

// MARK: - LegibilityShadowModifier

private struct LegibilityShadowModifier: ViewModifier {
    // MARK: Internal

    let isText: Bool

    var opacity: CGFloat {
        Self.contentLegibilityShadowOpacity * (isText ? 1 : 0.7)
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

    // MARK: Private

    private static let contentLegibilityShadowOpacity = 0.7
}

extension View {
    @ViewBuilder
    public func legibilityShadow(isText: Bool = true, enabled: Bool = true) -> some View {
        switch enabled {
        case true: modifier(LegibilityShadowModifier(isText: isText))
        case false: self
        }
    }
}
