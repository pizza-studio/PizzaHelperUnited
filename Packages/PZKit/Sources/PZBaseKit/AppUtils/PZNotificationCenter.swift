// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import UserNotifications

public enum PZNotificationCenter {
    public static let center = UNUserNotificationCenter.current()

    public static func printAllNotifications() async {
        await center.pendingNotificationRequests().forEach { request in
            print(request.content.title)
            print(request.content.body)
            print(request.identifier)
            print(request.trigger ?? "")
        }
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
