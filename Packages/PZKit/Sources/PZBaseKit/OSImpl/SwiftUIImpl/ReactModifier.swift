// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

extension View {
    /// Observes changes to a value, invoking the action with the new value and the old value.
    /// - Note: The action captures values corresponding to the new state, consistent with iOS 17's `.onChange`. For `initial: true`, the old value is passed as the current value to mimic non-nil behavior.
    @ViewBuilder
    public func react<V>(
        to value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    )
        -> some View where V: Equatable {
        modifier(
            ComparableReactModifier(
                value: value,
                initial: initial,
                action: action
            )
        )
    }

    /// Observes changes to a value, invoking the action without parameters.
    /// - Note: The action is triggered based on the new state, consistent with iOS 17's `.onChange`.
    @ViewBuilder
    public func react<V>(
        to value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    )
        -> some View where V: Equatable {
        modifier(
            ReactModifier(
                value: value,
                initial: initial,
                action: action
            )
        )
    }
}

// MARK: - ComparableReactModifier

private struct ComparableReactModifier<V: Equatable>: ViewModifier {
    // MARK: Lifecycle

    public init(
        value: V,
        initial: Bool,
        action: @escaping (V, V) -> Void
    ) {
        self.value = value
        self.initial = initial
        self.action = action
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .onChange(of: value) { newValue in
                action(oldValue ?? value, newValue)
                oldValue = newValue
            }
            .onAppear {
                if initial {
                    // 初始调用，模仿 iOS 17 的 oldValue 为 nil，但由于签名限制，使用 value
                    action(value, value)
                    oldValue = value
                }
            }
    }

    // MARK: Private

    @State private var oldValue: V?

    private let value: V
    private let initial: Bool
    private let action: (V, V) -> Void
}

// MARK: - ReactModifier

private struct ReactModifier<V: Equatable>: ViewModifier {
    // MARK: Lifecycle

    public init(
        value: V,
        initial: Bool,
        action: @escaping () -> Void
    ) {
        self.value = value
        self.initial = initial
        self.action = action
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .onChange(of: value) { newValue in
                action()
                oldValue = newValue
            }
            .onAppear {
                if initial {
                    action()
                    oldValue = value
                }
            }
    }

    // MARK: Private

    @State private var oldValue: V?

    private let value: V
    private let initial: Bool
    private let action: () -> Void
}
