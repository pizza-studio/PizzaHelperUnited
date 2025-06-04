// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(watchOS, unavailable)
extension View {
    @ViewBuilder
    func myWidgetContainerBackground<V: View>(
        withPadding padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(padding: padding, background: content))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let padding: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .containerBackground(for: .widget) {
                background()
            }
    }
}
