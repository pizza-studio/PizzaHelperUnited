// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

// MARK: - FocusableModifier

private struct FocusableModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if #unavailable(iOS 17.0, macCatalyst 17.0, macOS 14.0) {
            content
        } else {
            #if os(watchOS)
            content
            #else
            content.focusable(enabled)
            #endif
        }
    }
}

// 扩展 View 以便方便使用。对外仅曝露这个 API。
extension View {
    public func disableFocusable() -> some View {
        modifier(FocusableModifier(enabled: false))
    }

    public func enableFocusable() -> some View {
        modifier(FocusableModifier(enabled: true))
    }
}
