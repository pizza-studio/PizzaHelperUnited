// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

public let appGame: Pizza.SupportedGame? = .none

public let sharedBundleIDHeader: String = {
    let fallback = "org.pizzastudio.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "Canglong.GenshinPizzaHepler" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "Canglong.HSRPizzaHelper" }
    return fallback
}()

public let appGroupID: String = {
    let fallback = "group.pizzastudio.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "group.GenshinPizzaHelper" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "group.Canglong.HSRPizzaHelper" }
    return fallback
}()

public let iCloudContainerName: String = {
    let fallback = "iCloud.com.Canglong.UnitedPizzaHelper"
    guard let bID = Bundle.main.bundleIdentifier else { return fallback }
    if bID.hasPrefix("Canglong.GenshinPizzaHepler") { return "iCloud.com.Canglong.GenshinPizzaHepler" }
    if bID.hasPrefix("Canglong.HSRPizzaHelper") { return "iCloud.com.Canglong.HSRPizzaHelper" }
    return fallback
}()

public let groupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)

extension Pizza {
    public static let isAppStoreRelease: Bool = {
        Bundle.main.bundleIdentifier?.hasPrefix("Canglong.GenshinPizzaHepler") ?? false
    }()

    public static let isWidgetExtension: Bool = {
        guard let bID = Bundle.main.bundleIdentifier?.lowercased() else { return false }
        return bID.hasSuffix("extension") || bID.hasSuffix("widget")
    }()
}
