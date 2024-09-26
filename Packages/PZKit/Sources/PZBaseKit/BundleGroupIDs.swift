// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

#if PizzaHelper4Genshin
public let sharedBundleIDHeader = "Canglong.GenshinPizzaHepler"
public let appGroupID = "group.GenshinPizzaHelper"
public let iCloudContainerName: String = "iCloud.com.Canglong.GenshinPizzaHepler"
public let appGame: Pizza.SupportedGame? = .genshinImpact
#elseif PizzaHelper4HSR
public let sharedBundleIDHeader = "Canglong.HSRPizzaHelper"
public let appGroupID = "group.Canglong.HSRPizzaHelper"
public let iCloudContainerName: String = "iCloud.com.Canglong.HSRPizzaHelper"
public let appGame: Pizza.SupportedGame? = .starRail
#else
public let appGame: Pizza.SupportedGame? = .none

public let sharedBundleIDHeader: String = {
    switch Bundle.main.bundleIdentifier {
    case "Canglong.GenshinPizzaHepler": "Canglong.GenshinPizzaHepler"
    case "Canglong.HSRPizzaHelper": "Canglong.HSRPizzaHelper"
    default: "org.pizzastudio.UnitedPizzaHelper"
    }
}()

public let appGroupID: String = {
    switch Bundle.main.bundleIdentifier {
    case "Canglong.GenshinPizzaHepler": "group.GenshinPizzaHelper"
    case "Canglong.HSRPizzaHelper": "group.Canglong.HSRPizzaHelper"
    default: "group.pizzastudio.UnitedPizzaHelper"
    }
}()

public let iCloudContainerName: String = {
    switch Bundle.main.bundleIdentifier {
    case "Canglong.GenshinPizzaHepler": "iCloud.com.Canglong.GenshinPizzaHepler"
    case "Canglong.HSRPizzaHelper": "iCloud.com.Canglong.HSRPizzaHelper"
    default: "iCloud.com.Canglong.UnitedPizzaHelper"
    }
}()

#endif
