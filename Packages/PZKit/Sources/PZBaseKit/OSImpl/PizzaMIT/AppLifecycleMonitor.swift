// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

#if !os(watchOS)

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - AppLifecycleMonitor

/// Cross-platform monitor for app foreground/background transitions.
///
/// Attach async handlers via `onEnterBackground(_:)` / `onEnterForeground(_:)`.
/// Each call returns an ``ObserverToken`` that automatically unregisters on deinit.
/// Monitoring starts on first registration and stops when all tokens are released.
///
/// - On iOS / Mac Catalyst: uses `UIApplication` notifications.
/// - On native AppKit macOS: uses `NSApplication` notifications.
public final class AppLifecycleMonitor: @unchecked Sendable {
    // MARK: Public

    /// Registers a handler called when the app enters the background.
    /// Returns a token; the monitor unregisters when all tokens are deallocated.
    public static func onEnterBackground(
        _ handler: @Sendable @escaping () async -> Void
    )
        -> ObserverToken {
        shared.register(tokenFor: .background, handler: handler)
    }

    /// Registers a handler called when the app returns to the foreground.
    /// Returns a token; the monitor unregisters when all tokens are deallocated.
    public static func onEnterForeground(
        _ handler: @Sendable @escaping () async -> Void
    )
        -> ObserverToken {
        shared.register(tokenFor: .foreground, handler: handler)
    }

    // MARK: Fileprivate

    fileprivate enum Event { case background, foreground }

    fileprivate func unregister(_ token: ObserverToken) {
        _ = lock.withLock {
            switch token.event {
            case .background: backgroundTokens.remove(token)
            case .foreground: foregroundTokens.remove(token)
            }
        }
        if lock.withLock({ backgroundTokens.isEmpty && foregroundTokens.isEmpty }) {
            NotificationCenter.default.removeObserver(self)
            isObserving = false
        }
    }

    // MARK: Private

    private static let shared = AppLifecycleMonitor()

    private static var backgroundNotificationName: Notification.Name {
        #if canImport(UIKit)
        UIApplication.didEnterBackgroundNotification
        #elseif canImport(AppKit)
        NSApplication.willResignActiveNotification
        #else
        preconditionFailure("Unsupported platform")
        #endif
    }

    private static var foregroundNotificationName: Notification.Name {
        #if canImport(UIKit)
        UIApplication.willEnterForegroundNotification
        #elseif canImport(AppKit)
        NSApplication.didBecomeActiveNotification
        #else
        preconditionFailure("Unsupported platform")
        #endif
    }

    private let lock = NSLock()
    private var backgroundTokens: Set<ObserverToken> = []
    private var foregroundTokens: Set<ObserverToken> = []
    private var isObserving = false

    private func register(
        tokenFor event: Event,
        handler: @Sendable @escaping () async -> Void
    )
        -> ObserverToken {
        let token = ObserverToken(monitor: self, event: event, handler: handler)
        _ = lock.withLock {
            switch event {
            case .background: backgroundTokens.insert(token)
            case .foreground: foregroundTokens.insert(token)
            }
        }
        startObservingIfNeeded()
        return token
    }

    private func startObservingIfNeeded() {
        guard !isObserving else { return }
        isObserving = true
        let nc = NotificationCenter.default
        nc.addObserver(
            self, selector: #selector(fireBackground),
            name: Self.backgroundNotificationName, object: nil
        )
        nc.addObserver(
            self, selector: #selector(fireForeground),
            name: Self.foregroundNotificationName, object: nil
        )
    }

    @objc
    private func fireBackground() {
        for token in lock.withLock({ backgroundTokens }) {
            Task { await token.handler() }
        }
    }

    @objc
    private func fireForeground() {
        for token in lock.withLock({ foregroundTokens }) {
            Task { await token.handler() }
        }
    }
}

// MARK: - ObserverToken

extension AppLifecycleMonitor {
    /// Opaque token that keeps an observation alive.
    /// The handler is automatically unregistered when this token is deallocated.
    public final class ObserverToken: Hashable, @unchecked Sendable {
        // MARK: Lifecycle

        fileprivate init(
            monitor: AppLifecycleMonitor,
            event: AppLifecycleMonitor.Event,
            handler: @Sendable @escaping () async -> Void
        ) {
            self.monitor = monitor
            self.event = event
            self.handler = handler
        }

        deinit { monitor?.unregister(self) }

        // MARK: Public

        public static func == (lhs: ObserverToken, rhs: ObserverToken) -> Bool {
            lhs === rhs
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }

        // MARK: Fileprivate

        fileprivate let event: AppLifecycleMonitor.Event
        fileprivate let handler: @Sendable () async -> Void

        // MARK: Private

        private weak var monitor: AppLifecycleMonitor?
    }
}

#endif
