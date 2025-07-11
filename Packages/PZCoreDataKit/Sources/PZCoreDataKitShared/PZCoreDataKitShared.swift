// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - PZCoreDataKit

public enum PZCoreDataKit {
    public static let isAppStoreRelease: Bool = {
        Bundle.main.bundleIdentifier?.hasPrefix("Canglong.GenshinPizzaHepler") ?? false
    }()

    public static let isNotMainApp: Bool = {
        guard let bID = Bundle.main.bundleIdentifier?.lowercased() else { return false }
        return bID.hasSuffix("extension") || bID.hasSuffix("widget") || bID.contains("intents")
    }()

    public static var sharedBundleIDHeader: String {
        let fallback = "org.pizzastudio.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "Canglong.GenshinPizzaHepler" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "Canglong.HSRPizzaHelper" }
        return fallback
    }

    public static var appGroupID: String {
        let fallback = "group.pizzastudio.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "group.GenshinPizzaHelper" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "group.Canglong.HSRPizzaHelper" }
        return fallback
    }

    public static var iCloudContainerName: String {
        let fallback = "iCloud.com.Canglong.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "iCloud.com.Canglong.GenshinPizzaHepler" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "iCloud.com.Canglong.HSRPizzaHelper" }
        return fallback
    }

    public static var groupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    /// Retrieves the URL of the folder where the `WidgetBackground`s are stored in the documents directory.
    /// - Parameter folderName: The name of the folder where the `WidgetBackground`s are stored.
    /// - Returns: The URL of the folder where the `WidgetBackground`s are stored in the documents directory.
    public static func documentBackgroundFolderUrl(folderName: String) throws -> URL {
        let backgroundFolderUrl = groupContainerURL!
            .appendingPathComponent("UserSuppliedWallpapers", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(
            at: backgroundFolderUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderUrl
    }
}
