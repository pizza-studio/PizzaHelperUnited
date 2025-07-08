// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(WatchConnectivity)
import Defaults
import Foundation
import PZBaseKit
import PZProfileCDMOBackports
import SwiftData
import WatchConnectivity

// MARK: - AppleWatchSputnik

public final class AppleWatchSputnik: NSObject, ObservableObject {
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

    @MainActor public static let shared = AppleWatchSputnik()

    public static var isSupported: Bool {
        WCSession.isSupported()
    }

    @Published public var notificationMessage: NotificationMessage?

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

    public func sendAccounts(_ accounts: [PZProfileSendable], _ message: String) {
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

        var accountMap = [String: PZProfileSendable]()
        accounts.forEach {
            accountMap[$0.uidWithGame] = $0
        }

        let jsonData = try! JSONEncoder().encode(accountMap)
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

extension AppleWatchSputnik: WCSessionDelegate {
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        #if os(watchOS)
        do {
            let data = try JSONSerialization.data(withJSONObject: message as NSDictionary)
            let receivedProfileMap = try JSONDecoder().decode([String: PZProfileSendable].self, from: data)
            // sharedAccounts.append(accountReceived)
            if let notificationText = message[kMessageKey] as? String {
                notificationMessage = NotificationMessage(text: notificationText)
            }
            print("Received profiles")

            Task {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                if await !assertion.state.isReleased {
                    await PZProfileActor.shared.watchSessionHandleIncomingPushedProfiles(receivedProfileMap)
                    // await CDProfileMOActor.shared.watchSessionHandleIncomingPushedProfiles(receivedProfileMap)
                }
                await assertion.release()
            }
        } catch {
            print("save profile failed: \(error)")
        }
        #endif
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

#if os(watchOS)
extension CDProfileMOActor {
    /// 将来 watchOS 需要降级的话，会用到这个 API。
    public func watchSessionHandleIncomingPushedProfiles(_ receivedProfileMap: [String: PZProfileSendable]) {
        do {
            var receivedProfileMap = receivedProfileMap
            try container.perform { context in
                let fetchedCDMOObjs = try context.fetch(PZProfileCDMO.all)

                // 如果有既有重複記錄的話，先刪得只剩一個，然後覆蓋其所有資料欄目值。
                if !fetchedCDMOObjs.isEmpty {
                    var uidHandled = Set<String>()
                    try fetchedCDMOObjs.forEach { oldProfileCDMOObj in
                        var oldProfile = try oldProfileCDMOObj.decode()
                        let matched = receivedProfileMap[oldProfile.uidWithGame]
                        guard let matched else {
                            // 删除已经不存在的 Profile。
                            PZNotificationCenter.deleteDailyNoteNotification(for: oldProfile.asSendable)
                            context.delete(oldProfileCDMOObj)
                            return
                        }
                        if !uidHandled.contains(oldProfile.uidWithGame) {
                            let uuidBackup = oldProfile.uuid
                            oldProfile.inherit(from: matched)
                            oldProfile.uuid = uuidBackup
                            oldProfileCDMOObj.encode(oldProfile)
                            PZNotificationCenter.bleachNotificationsIfDisabled(for: oldProfile.asSendable)
                            uidHandled.insert(oldProfile.uidWithGame)
                        } else {
                            // 删除已经处理过的重复的 Profile。
                            PZNotificationCenter.deleteDailyNoteNotification(for: oldProfile.asSendable)
                            context.delete(oldProfileCDMOObj)
                            return
                        }
                    }
                    // 筛选掉已经处理过的传入的 profile，然后就只剩下需要全新插入的 profile。
                    uidHandled.forEach { receivedProfileMap.removeValue(forKey: $0) }
                }

                try receivedProfileMap.values.forEach {
                    try context.insert($0.asCDMO)
                    PZNotificationCenter.bleachNotificationsIfDisabled(for: $0)
                }
            }

            Defaults[.pzProfiles].removeAll()
            receivedProfileMap.values.forEach {
                Defaults[.pzProfiles][$0.uuid.uuidString] = $0
            }
            UserDefaults.profileSuite.synchronize()
        } catch {
            print("save profile failed: \(error)")
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZProfileActor {
    public func watchSessionHandleIncomingPushedProfiles(
        _ receivedProfileMap: [String: PZProfileSendable]
    ) {
        do {
            var receivedProfileMap = receivedProfileMap
            try modelContext.transaction {
                // 開始處理資料插入。
                let descriptor = FetchDescriptor<PZProfileMO>()
                let fetched = (try? modelContext.fetch(descriptor)) ?? []
                // 如果有既有重複記錄的話，先刪得只剩一個，然後覆蓋其所有資料欄目值。
                if !fetched.isEmpty {
                    var uidHandled = Set<String>()
                    fetched.forEach { oldProfile in
                        let matched = receivedProfileMap[oldProfile.uidWithGame]
                        guard let matched else {
                            // 删除已经不存在的 Profile。
                            PZNotificationCenter.deleteDailyNoteNotification(for: oldProfile.asSendable)
                            modelContext.delete(oldProfile)
                            return
                        }
                        if !uidHandled.contains(oldProfile.uidWithGame) {
                            let uuidBackup = oldProfile.uuid
                            oldProfile.inherit(from: matched)
                            oldProfile.uuid = uuidBackup
                            PZNotificationCenter.bleachNotificationsIfDisabled(for: oldProfile.asSendable)
                            uidHandled.insert(oldProfile.uidWithGame)
                        } else {
                            // 删除已经处理过的重复的 Profile。
                            PZNotificationCenter.deleteDailyNoteNotification(for: oldProfile.asSendable)
                            modelContext.delete(oldProfile)
                            return
                        }
                    }
                    // 筛选掉已经处理过的传入的 profile，然后就只剩下需要全新插入的 profile。
                    uidHandled.forEach { receivedProfileMap.removeValue(forKey: $0) }
                }
                receivedProfileMap.values.forEach {
                    modelContext.insert($0.asMO)
                    PZNotificationCenter.bleachNotificationsIfDisabled(for: $0)
                }
            }
            Defaults[.pzProfiles].removeAll()
            receivedProfileMap.values.forEach {
                Defaults[.pzProfiles][$0.uuid.uuidString] = $0
            }
            UserDefaults.profileSuite.synchronize()
        } catch {
            print("save profile failed: \(error)")
        }
    }
}
#endif
