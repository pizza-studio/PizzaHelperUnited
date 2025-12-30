// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - PZCoreDataKit

public enum PZCoreDataKit {
    public static let isAppStoreReleaseAsPizzaHelper: Bool = {
        Bundle.main.bundleIdentifier?.hasPrefix("Canglong.GenshinPizzaHepler") ?? false
    }()

    public static let isAppStoreReleaseAsLatteHelper: Bool = {
        Bundle.main.bundleIdentifier?.hasPrefix("org.pizzastudio.TheLatteHelper") ?? false
    }()

    public static let isNotMainApp: Bool = {
        guard let bID = Bundle.main.bundleIdentifier?.lowercased() else { return false }
        return bID.hasSuffix("extension") || bID.hasSuffix("widget") || bID.contains("intents")
    }()

    public static let sharedBundleIDHeader: String = {
        guard !isAppStoreReleaseAsLatteHelper else {
            return "org.pizzastudio.TheLatteHelper"
        }
        let fallback = "org.pizzastudio.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "Canglong.GenshinPizzaHepler" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "Canglong.HSRPizzaHelper" }
        return fallback
    }()

    public static let appGroupID: String = {
        guard !isAppStoreReleaseAsLatteHelper else {
            return "group.pizzastudio.TheLatteHelper"
        }
        let fallback = "group.pizzastudio.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "group.GenshinPizzaHelper" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "group.Canglong.HSRPizzaHelper" }
        return fallback
    }()

    public static let iCloudContainerName: String = {
        guard !isAppStoreReleaseAsLatteHelper else {
            return "iCloud.com.pizzastudio.TheLatteHelper"
        }
        let fallback = "iCloud.com.Canglong.UnitedPizzaHelper"
        guard let bID = Bundle.main.bundleIdentifier else { return fallback }
        if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "iCloud.com.Canglong.GenshinPizzaHepler" }
        if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "iCloud.com.Canglong.HSRPizzaHelper" }
        return fallback
    }()

    public static var isAppStoreRelease: Bool {
        isAppStoreReleaseAsPizzaHelper || isAppStoreReleaseAsLatteHelper
    }

    public static var groupContainerURL: URL? {
        // 拿铁小助手不需要启用 CoreData 支持。
        guard !isAppStoreReleaseAsLatteHelper else { return nil }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }
}
