// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - DesktopWidgets

@available(watchOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
public enum DesktopWidgets {}

// MARK: - EmbeddedWidgets

@available(macOS, unavailable)
@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
public enum EmbeddedWidgets {}

#if os(macOS) && !targetEnvironment(macCatalyst)
import SwiftUI

@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
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
