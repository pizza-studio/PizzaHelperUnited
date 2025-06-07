// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - WidgetAccessibilityBackground

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
    public func widgetAccessibilityBackground(enabled: Bool) -> some View {
        modifier(WidgetAccessibilityBackground(enabled: enabled))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .containerBackground(for: .widget) {
                background()
            }
    }

    // MARK: Internal

    let padding: CGFloat
    let background: () -> V
}

@available(watchOS, unavailable)
extension View {
    @ViewBuilder
    public func myWidgetContainerBackground<V: View>(
        withPadding padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(padding: padding, background: content))
    }
}
