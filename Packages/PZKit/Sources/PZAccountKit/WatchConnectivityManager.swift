// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(WatchConnectivity)
import CoreData
import Foundation
import SwiftData
import WatchConnectivity

// MARK: - NotificationMessage

// MARK: - WatchConnectivityManager

@Observable
public final class WatchConnectivityManager: NSObject, ObservableObject {
    // MARK: Lifecycle

    private override init() {
        super.init()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: Public

    public struct NotificationMessage: Identifiable, Sendable {
        public let id = UUID()
        public let text: String
    }

    @MainActor public static let shared = WatchConnectivityManager()

    public static var isSupported: Bool {
        WCSession.isSupported()
    }

    public var notificationMessage: NotificationMessage?

    // var sharedAccounts = [PZProfileMO]() // 完全沒用到。

    public func send(_ message: String) {
        print("Send message")
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if !os(watchOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif

        WCSession.default.sendMessage([kMessageKey: message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }

    public func sendAccounts(_ account: PZProfileMO, _ message: String) {
        print("Send account")
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if !os(watchOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif

        let jsonData = try! JSONEncoder().encode(account)
        let nsDictData = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]

        WCSession.default.sendMessage(nsDictData, replyHandler: nil) { error in
            print("Cannot send accounts: \(String(describing: error))")
        }
    }

    // MARK: Private

    private let kMessageKey = "message"
    private let kAccountKey = "account"
}

// MARK: WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let notificationText = message[kMessageKey] as? String {
            notificationMessage = NotificationMessage(text: notificationText)
        }
        print("Received accounts")
        let data = try! JSONSerialization.data(withJSONObject: message as NSDictionary)
        let accountReceived = try! JSONDecoder().decode(PZProfileMO.self, from: data)

        let context = ModelContext(PZProfileActor.shared.modelContainer)
        context.insert(accountReceived)
        do {
            try context.save()
        } catch {
            print("save account failed: \(error)")
        }
        // sharedAccounts.append(accountReceived)
    }

    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    #if !os(watchOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
#endif
