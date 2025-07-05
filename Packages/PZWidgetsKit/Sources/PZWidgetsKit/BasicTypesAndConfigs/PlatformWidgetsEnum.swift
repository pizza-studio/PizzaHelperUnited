// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - DesktopWidgets

#if !os(watchOS)

@available(watchOS, unavailable)
public enum DesktopWidgets {}

#endif

// MARK: - EmbeddedWidgets

#if !os(macOS)

@available(macOS, unavailable)
public enum EmbeddedWidgets {}

#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import SwiftUI

extension View {
    @MainActor @preconcurrency
    public func widgetLabel(_ label: any StringProtocol) -> some View {
        self
    }

    @MainActor @preconcurrency
    public func widgetLabel<Label>(@ViewBuilder label: () -> Label) -> some View where Label: View {
        label()
    }
}
#endif
