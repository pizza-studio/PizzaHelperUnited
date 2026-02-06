// This implementation is considered as copyleft from public domain.

import Foundation

// MARK: - NSMutex

/// A simple NSMutex implementation using NSLock for macOS 10.9+ compatibility.
/// Provides thread-safe access to a wrapped value.
nonisolated public final class NSMutex<Value>: Sendable {
    // MARK: Lifecycle

    public init(_ value: Value) {
        self.storedValue = value
    }

    // MARK: Public

    public var value: Value {
        get {
            withLock { $0 }
        }
        set {
            withLock { $0 = newValue }
        }
    }

    /// Access the value with exclusive access (read and write).
    public func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        try lock.withLock { try body(&storedValue) }
    }

    /// Read the value with exclusive access (read-only).
    public func withLockRead<Result>(_ body: (Value) throws -> Result) rethrows -> Result {
        try lock.withLock { try body(storedValue) }
    }

    // MARK: Private

    nonisolated(unsafe) private var storedValue: Value
    private let lock = NSLock()
}
