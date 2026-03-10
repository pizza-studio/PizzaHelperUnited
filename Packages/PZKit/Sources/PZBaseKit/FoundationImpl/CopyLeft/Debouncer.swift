// This implementation is considered as copyleft from public domain.

import Foundation

// MARK: - Debouncer

public actor Debouncer {
    // MARK: Lifecycle

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: Public

    public func debounce(
        keepFirstAttemptInstead: Bool = false,
        _ action: @Sendable @escaping () async -> Void
    ) async {
        if keepFirstAttemptInstead {
            guard !isInExclusiveState else { return }
            // Set exclusive state synchronously within the actor's
            // serial execution so subsequent calls see it before this method returns.
            isInExclusiveState = true
        }
        task?.cancel()
        task = Task { @MainActor [weak self] in
            guard let self else { return }
            if !keepFirstAttemptInstead {
                await setExclusiveState(true)
            }
            if keepFirstAttemptInstead {
                await action()
            }
            let sleepSucceeded: Bool
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                sleepSucceeded = true
            } catch {
                sleepSucceeded = false
            }
            // Always reset exclusive state, even on cancellation.
            await setExclusiveState(false)
            guard sleepSucceeded, !Task.isCancelled else { return }
            if !keepFirstAttemptInstead {
                await action()
            }
        }
    }

    nonisolated public func debounceOnMain(
        keepFirstAttemptInstead: Bool = false,
        _ action: @MainActor @escaping () async -> Void
    ) {
        Task {
            await debounce(keepFirstAttemptInstead: keepFirstAttemptInstead) {
                await action()
            }
        }
    }

    // Cancel any pending debounced task.
    // Used by double-click to prevent single-click from executing.
    public func cancel() async {
        task?.cancel()
        isInExclusiveState = false
    }

    nonisolated public func cancelOnMain() {
        Task {
            await cancel()
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
    private var isInExclusiveState: Bool = false
    private let delay: TimeInterval

    private func setExclusiveState(_ newValue: Bool) {
        isInExclusiveState = newValue
    }
}
