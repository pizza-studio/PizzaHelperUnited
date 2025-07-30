// This implementation is considered as copyleft from public domain.

import Foundation

// MARK: - Debouncer

public actor Debouncer {
    // MARK: Lifecycle

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: Public

    public func debounce(_ action: @escaping @MainActor () async -> Void) async {
        task?.cancel()
        task = Task { @MainActor [weak self] in
            guard let self else { return }
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            try Task.checkCancellation()
            await action()
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
    private let delay: TimeInterval
}
