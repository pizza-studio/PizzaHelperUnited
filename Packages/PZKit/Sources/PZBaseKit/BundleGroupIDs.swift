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
    public enum AppStoreURL: String {
        case asPizzaHelper = "https://apps.apple.com/app/id1635319193"
        case asLatteHelper = "https://apps.apple.com/app/id6757201427"
    }

    public static var isAppStoreRelease: Bool {
        isAppStoreReleaseAsPizzaHelper || isAppStoreReleaseAsLatteHelper
    }

    public static var urlString4AppStore: String? {
        if isAppStoreReleaseAsPizzaHelper {
            return AppStoreURL.asPizzaHelper.rawValue
        } else if isAppStoreReleaseAsLatteHelper {
            return AppStoreURL.asLatteHelper.rawValue
        } else {
            return nil
        }
    }

    public static var url4AppStore: URL? {
        guard let urlString4AppStore else { return nil }
        return URL(string: urlString4AppStore)
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

extension Pizza {
    public static var appTitleLocalizedFull: String {
        let key = isAppStoreReleaseAsLatteHelper
            ? "app.title.latte.full"
            : "app.title.pizza.full"
        return key.i18nBaseKit
    }

    public static var appTitleLocalizedShort: String {
        let key = isAppStoreReleaseAsLatteHelper
            ? "app.title.latte.short"
            : "app.title.pizza.short"
        return key.i18nBaseKit
    }
}
