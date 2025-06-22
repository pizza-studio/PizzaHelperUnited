// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - DesktopWidgets

@available(watchOS, unavailable)
public enum DesktopWidgets {}

// MARK: - EmbeddedWidgets

@available(macOS, unavailable)
public enum EmbeddedWidgets {}

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
