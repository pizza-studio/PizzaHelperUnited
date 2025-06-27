// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

import SwiftUI

// MARK: - CanvasSizeTracker

private struct CanvasSizeTracker: ViewModifier {
    // MARK: Lifecycle

    public init(handler: @escaping (CGSize) -> Void, debounceDelay: TimeInterval = 0.1) {
        self.handler = handler
        self._sizeState = .init(wrappedValue: SizeState(debounceDelay: debounceDelay))
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .background {
                Color.clear
                    .containerRelativeFrame(.horizontal) { width, _ in
                        sizeState.update(width: width)
                        dispatchHandlerIfValid()
                        return width
                    }
                    .containerRelativeFrame(.vertical) { height, _ in
                        sizeState.update(height: height)
                        dispatchHandlerIfValid()
                        return height
                    }
            }
    }

    // MARK: Private

    @StateObject private var sizeState: SizeState

    private let handler: (CGSize) -> Void

    private func dispatchHandlerIfValid() {
        if sizeState.size.width > 0, sizeState.size.height > 0 {
            sizeState.debounce { size in
                handler(size)
            }
        }
    }
}

// MARK: - SizeState

@Observable @MainActor
private class SizeState: ObservableObject {
    // MARK: Lifecycle

    init(debounceDelay: TimeInterval) {
        self.debounceDelay = debounceDelay
    }

    // MARK: Internal

    var size: CGSize = .zero

    func update(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            size.width = width
        }
        if let height = height {
            size.height = height
        }
    }

    func debounce(_ action: @escaping @MainActor (CGSize) -> Void) {
        // 取消之前的任务
        task?.cancel()

        // 创建新任务
        let newTask = Task { @MainActor in
            // 等待指定的延迟时间
            try await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))

            // 检查任务是否被取消
            try Task.checkCancellation()

            // 执行动作
            action(size)
        }

        // 存储新任务
        task = newTask
    }

    // MARK: Private

    @ObservationIgnored private var task: Task<Void, Error>?
    private let debounceDelay: TimeInterval
}

extension View {
    public func trackCanvasSize(
        debounceDelay: TimeInterval = 0.1,
        handler: @escaping @MainActor (CGSize) -> Void
    )
        -> some View {
        modifier(CanvasSizeTracker(handler: handler, debounceDelay: debounceDelay))
    }
}
