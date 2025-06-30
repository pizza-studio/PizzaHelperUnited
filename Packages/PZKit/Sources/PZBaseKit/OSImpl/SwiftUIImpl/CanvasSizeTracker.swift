// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

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
                    .containerRelativeFrame([.horizontal, .vertical]) { length, axis in
                        switch axis {
                        case .horizontal:
                            sizeState.update(width: length)
                        case .vertical:
                            sizeState.update(height: length)
                        }
                        dispatchHandlerIfValid()
                        return length
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

/// This doesn't need to be @Observable,
/// but we use ObservableObject to hinder it from being reinitialized again-and-again.
@MainActor
private class SizeState: ObservableObject {
    // MARK: Lifecycle

    init(debounceDelay: TimeInterval) {
        self.debounceDelay = debounceDelay
    }

    // MARK: Internal

    var size: CGSize = .zero

    func update(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width, width.isFinite, width >= 0 {
            size.width = width
        }
        if let height = height, height.isFinite, height >= 0 {
            size.height = height
        }
    }

    func debounce(_ action: @escaping @MainActor (CGSize) -> Void) {
        task?.cancel()
        task = Task { @MainActor in
            try await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
            try Task.checkCancellation()
            action(size)
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
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
