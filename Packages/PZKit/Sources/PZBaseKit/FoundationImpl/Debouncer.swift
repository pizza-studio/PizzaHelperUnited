// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

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
