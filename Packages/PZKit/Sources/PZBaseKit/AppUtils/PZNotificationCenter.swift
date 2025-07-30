// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

@preconcurrency import UserNotifications

public enum PZNotificationCenter {
    @MainActor public static let center = UNUserNotificationCenter.current()

    public static func printAllNotifications() async {
        await center.pendingNotificationRequests().forEach { request in
            print(request.content.title)
            print(request.content.body)
            print(request.identifier)
            print(request.trigger ?? "")
        }
    }

    public static func removeAllPendingNotifications() async {
        let identifiers = await center.pendingNotificationRequests().map(\.identifier)
        await center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    public static func getAllNotificationsDescriptions() async -> [String] {
        var strings = [String]()
        await center.pendingNotificationRequests().forEach { request in
            let description = """
            [\(request.identifier)\n\(request.content.title)]\n\(
                request.content
                    .body
            )\n(\(String(describing: request.trigger?.description)))\n
            """
            strings.append(description)
        }
        return strings
    }

    public static func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    public static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
}
