// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WidgetKit

// MARK: - WidgetAccessibilityBackground

@available(iOS 16.2, macCatalyst 16.2, *)
private struct WidgetAccessibilityBackground: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    public func widgetAccessibilityBackground(enabled: Bool) -> some View {
        if #available(iOS 16.2, macCatalyst 16.2, *) {
            modifier(WidgetAccessibilityBackground(enabled: enabled))
        } else {
            self
        }
    }
}
