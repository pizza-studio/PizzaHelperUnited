// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation

public let appGame: Pizza.SupportedGame? = .none

public let sharedBundleIDHeader: String = {
    guard !Pizza.isAppStoreReleaseAsLatteHelper else {
        return "org.pizzastudio.TheLatteHelper"
    }
    let fallback = "org.pizzastudio.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "Canglong.GenshinPizzaHepler" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "Canglong.HSRPizzaHelper" }
    return fallback
}()

public let appGroupID: String = {
    guard !Pizza.isAppStoreReleaseAsLatteHelper else {
        return "group.pizzastudio.TheLatteHelper"
    }
    let fallback = "group.pizzastudio.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "group.GenshinPizzaHelper" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "group.Canglong.HSRPizzaHelper" }
    return fallback
}()

public let iCloudContainerName: String = {
    guard !Pizza.isAppStoreReleaseAsLatteHelper else {
        return "iCloud.com.pizzastudio.TheLatteHelper"
    }
    let fallback = "iCloud.com.Canglong.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "iCloud.com.Canglong.GenshinPizzaHepler" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "iCloud.com.Canglong.HSRPizzaHelper" }
    return fallback
}()

public let groupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)

extension Pizza {
    public static var isAppStoreRelease: Bool {
        isAppStoreReleaseAsPizzaHelper || isAppStoreReleaseAsLatteHelper
    }

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
}
