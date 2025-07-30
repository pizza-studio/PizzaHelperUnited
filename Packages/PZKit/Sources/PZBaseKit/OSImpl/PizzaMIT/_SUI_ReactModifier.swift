// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Combine
import Foundation
import SwiftUI

extension View {
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// - Remark: 这是 OS24 的 `.onChange(of:initial:_:)` 的向前移植版本，使用 Combine-Just 技术实现。
    /// 但这个实现会有额外的 Just 开销。
    /// 所以在 OS24+ 系统下，本 API 反而会改用 `.onChange(of:initial:_:)` 代劳。
    ///
    /// You can use `react` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. The old and new observed values are
    /// passed into the closure. In the following code example, `PlayerView`
    /// passes both the old and new values to the model.
    ///
    /// ```swift
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .react(to: playState) { oldState, newState in
    ///                 model.playStateDidChange(from: oldState, to: newState)
    ///             }
    ///         }
    ///     }
    /// ```
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///   - oldValue: The old value that failed the comparison check (or the
    ///     initial value when requested).
    ///   - newValue: The new value that failed the comparison check.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder
    public func react<V>(
        to value: V,
        initial: Bool = false,
        _ action: @escaping (V, V) -> Void
    )
        -> some View where V: Equatable {
        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(
                ComparableReactModifier(value: value, initial: initial, action: action)
            )
        }
    }

    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// - Remark: 这是 iOS 17 的 `.onChange(of:initial:_:)` 的向前移植版本，使用 Combine-Just 技术实现。
    /// 但这个实现会有额外的 Just 开销。
    /// 所以在 OS24+ 系统下，本 API 反而会改用 `.onChange(of:initial:_:)` 代劳。
    ///
    /// You can use `react` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. In the following code example,
    /// `PlayerView` calls into its model when `playState` changes model.
    ///
    /// ```swift
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .react(to: playState) {
    ///                 model.playStateDidChange(state: playState)
    ///             }
    ///         }
    ///     }
    /// ```
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder
    public func react<V>(
        to value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    )
        -> some View where V: Equatable {
        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            modifier(
                ReactModifier(value: value, initial: initial, action: action)
            )
        }
    }
}

// MARK: - ComparableReactModifier

private struct ComparableReactModifier<V: Equatable>: ViewModifier {
    // MARK: Lifecycle

    init(value: V, initial: Bool, action: @escaping (V, V) -> Void) {
        self.value = value
        self.initial = initial
        self.action = action
        self._lastValue = State(initialValue: value)
    }

    // MARK: Internal

    let value: V
    let initial: Bool
    let action: (V, V) -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(Just(value)) { newValue in
                guard !isInitialRun || initial else {
                    // 跳过初始运行（如果未启用 initial）
                    lastValue = newValue
                    isInitialRun = false
                    return
                }

                if newValue != lastValue {
                    // 执行回调：lastValue = 变化前的值，newValue = 变化后的值
                    action(lastValue, newValue)
                    lastValue = newValue
                }

                isInitialRun = false
            }
    }

    // MARK: Private

    @State private var lastValue: V
    @State private var isInitialRun = true
}

// MARK: - ReactModifier

private struct ReactModifier<V: Equatable>: ViewModifier {
    // MARK: Lifecycle

    init(value: V, initial: Bool, action: @escaping () -> Void) {
        self.value = value
        self.initial = initial
        self.action = action
        self._lastValue = State(initialValue: value)
    }

    // MARK: Internal

    let value: V
    let initial: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(Just(value)) { newValue in
                guard !isInitialRun || initial else {
                    lastValue = newValue
                    isInitialRun = false
                    return
                }

                if newValue != lastValue {
                    action()
                    lastValue = newValue
                }

                isInitialRun = false
            }
    }

    // MARK: Private

    @State private var lastValue: V
    @State private var isInitialRun = true
}
