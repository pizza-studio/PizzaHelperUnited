// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

// MARK: - CanvasSizeTracker

@available(iOS 16.0, macCatalyst 16.0, *)
private struct CanvasSizeTracker: ViewModifier {
    // MARK: Lifecycle

    public init(handler: @escaping (CGSize) -> Void, debounceDelay: TimeInterval = 0.1) {
        self.debounceDelay = debounceDelay
        self.handler = handler
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .background {
                SizeReadingLayout(onChange: { [weak sizeState] size in
                    Task { @MainActor in
                        guard let sizeState else { return }
                        sizeState.update(width: size.width, height: size.height)
                        sizeState.debounce(handler: handler)
                    }
                }) {
                    Color.clear
                }
            }
            .onAppear {
                // 确保 SizeState 的 debounceDelay 与当前参数保持一致。
                // 正常情况下 debounceDelay 不变，@State 会保留原有 SizeState；
                // 若 SwiftUI 因 view identity 变更而重建了 @State，这里至少保证
                // 新 SizeState 拿到正确的 debounceDelay。
                if sizeState.debounceDelay != debounceDelay {
                    sizeState = SizeState(debounceDelay: debounceDelay)
                }
            }
    }

    // MARK: Private

    @State private var sizeState: SizeState = .init(debounceDelay: 0.1)

    private let handler: (CGSize) -> Void
    private let debounceDelay: TimeInterval
}

// MARK: - SizeReadingLayout

/// 一个纯粹用于读取尺寸的 Layout，不干扰子视图的默认布局行为。
@available(iOS 16.0, macCatalyst 16.0, *)
private struct SizeReadingLayout: Layout {
    // MARK: Lifecycle

    init(onChange: @Sendable @escaping (CGSize) -> Void) {
        self.onChange = .init(onChange)
    }

    // MARK: Internal

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // 直接返回子视图（Color.clear）在当前建议下的大小
        // Color.clear 通常会填充建议的尺寸
        subviews.first?.sizeThatFits(proposal) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        // 放置子视图
        subviews.first?.place(at: bounds.origin, proposal: proposal)

        // 报告尺寸
        onChange.withLock { $0(bounds.size) }
    }

    // MARK: Private

    private let onChange: NSMutex<(CGSize) -> Void>
}

// MARK: - SizeState

/// This doesn't need to be @Observable.
@MainActor
private class SizeState {
    // MARK: Lifecycle

    init(debounceDelay: TimeInterval) {
        self.debounceDelay = debounceDelay
    }

    // MARK: Internal

    private(set) var debounceDelay: TimeInterval
    var size: CGSize = .zero

    func update(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width, width.isFinite, width >= 0 {
            size.width = width
        }
        if let height = height, height.isFinite, height >= 0 {
            size.height = height
        }
    }

    func debounce(handler: @escaping (CGSize) -> Void) {
        guard size.width > 0, size.height > 0 else { return }
        task?.cancel()
        task = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            try Task.checkCancellation()
            handler(size)
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
}

@available(iOS 16.0, macCatalyst 16.0, *)
extension View {
    @ViewBuilder
    public func trackCanvasSize(
        debounceDelay: TimeInterval = 0.1,
        handler: @escaping (CGSize) -> Void
    )
        -> some View {
        modifier(CanvasSizeTracker(handler: handler, debounceDelay: debounceDelay))
    }
}
