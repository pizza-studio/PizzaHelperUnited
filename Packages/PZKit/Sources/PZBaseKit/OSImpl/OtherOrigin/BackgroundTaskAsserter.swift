// (c) 2023 and onwards Quinn `the Eskimo` from Apple DTS Support.
// Ref: https://developer.apple.com/forums/thread/729335
// Refactored by 2025 Shiki Suen for Swfit 6 Strict Concurrency.

import Foundation

/// Prevents the process from suspending by holding a `ProcessInfo` expiry
/// activity assertion.
///
/// The assertion is released if:
///
/// * You explicitly release the assertion by calling ``release()``.
/// * There are no more strong references to the object and so it gets
///   deinitialized.
/// * The system ‘calls in’ the assertion, in which case it calls the
///   ``systemDidReleaseAssertion`` closure, if set.
///
/// You should aim to explicitly release the assertion yourself, as soon as
/// you’ve completed the work that the assertion covers.
///
/// This uses `ProcessInfo.performExpiringActivity(withReason:using:)`, which
/// is designed for CPU-bound work but is less ideal for I/O-bound tasks like
/// networking (r. 109839489). This implementation avoids blocking a Dispatch
/// worker thread by using Swift concurrency, improving efficiency compared to
/// the original semaphore-based approach.
public actor BackgroundTaskAsserter {
    // MARK: Lifecycle

    /// Creates an assertion with the given name.
    ///
    /// The name isn’t used by the system but it does show up in various logs so
    /// it’s important to choose one that’s meaningful to you.
    public init(name: String, didReleaseHandler: (@MainActor () -> Void)? = nil) {
        self.name = name
        self.state = AssertionState()
        self.systemDidReleaseAssertion = didReleaseHandler

        // Start the expiring activity
        #if os(macOS)
        ProcessInfo.processInfo.performActivity(reason: name) {
            self.fireInitialTask(didExpire: false)
        }
        #else
        ProcessInfo.processInfo.performExpiringActivity(
            withReason: name
        ) { didExpire in
            self.fireInitialTask(didExpire: didExpire)
        }
        #endif
    }

    deinit {
        Task { [state = self.state] in
            await state.cancelTaskIfNeeded()
        }
    }

    // MARK: Public

    /// Manages the state of the assertion in a thread-safe manner.
    public actor AssertionState {
        // MARK: Public

        public enum State {
            case starting
            case started(Task<Void, Never>)
            case released
        }

        public var currentTask: Task<Void, Never>? {
            guard case let .started(task) = state else { return nil }
            return task
        }

        public var isReleased: Bool {
            if case .released = state { return true }
            return false
        }

        public func transitionToStarted(task: Task<Void, Never>) {
            guard case .starting = state else { return }
            state = .started(task)
        }

        public func transitionToReleased() {
            switch state {
            case .started, .starting:
                state = .released
            case .released:
                break // Already released, no-op
            }
        }

        public func cancelTaskIfNeeded() {
            if case let .started(task) = state {
                task.cancel()
            }
            state = .released
        }

        // MARK: Private

        private var state: State = .starting
    }

    /// The name used when creating the assertion.
    public let name: String

    /// Called when the system releases the assertion itself.
    ///
    /// This is called on the main actor.
    ///
    /// To help avoid retain cycles, the object sets this to `nil` whenever the
    /// assertion is released.
    public var systemDidReleaseAssertion: (@MainActor () -> Void)?

    public let state: AssertionState

    /// Release the assertion.
    ///
    /// It’s safe to call this redundantly, that is, call it twice in a row or
    /// call it on an assertion that’s expired.
    public func release() async {
        await state.cancelTaskIfNeeded()
        Task {
            systemDidReleaseAssertion = nil
        }
    }

    // MARK: Private

    private func runSystemDidReleaseAssertion() {
        Task {
            await systemDidReleaseAssertion?()
            systemDidReleaseAssertion = nil
        }
    }

    nonisolated private func fireInitialTask(didExpire: Bool) {
        let task = Task {
            if didExpire {
                await state.transitionToReleased()
                await self.runSystemDidReleaseAssertion()
            } else {
                _ = await state.currentTask?.result
            }
        }
        Task {
            await state.transitionToStarted(task: task)
        }
    }
}
