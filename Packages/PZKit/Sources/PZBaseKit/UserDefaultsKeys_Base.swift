// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

extension UserDefaults {
    // 此处的 suiteName 得与 container ID 一致。
    public static let baseSuite = UserDefaults(suiteName: appGroupID) ?? .standard
}

extension Defaults.Keys {
    public static let cachedAppStoreMeta = Key<ASMeta?>(
        "cachedAppStoreMeta",
        default: nil,
        suite: .standard
    )

    /// App UI language. At least, this works with macOS. This must use the standard container.
    public static let appLanguage = Key<[String]?>(
        AppLanguage.defaultsKeyName,
        default: nil,
        suite: .standard
    )

    /// Remembering the most-recent tab index.
    public static let appTabIndex = Key<Int>(
        "appTabIndex",
        default: 1,
        suite: .baseSuite
    )

    /// Remembering the most-recent tab index.
    public static let restoreTabOnLaunching = Key<Bool>(
        "restoreTabOnLaunching",
        default: true,
        suite: .baseSuite
    )

    /// User-Specified Wanderer's name.
    public static let customizedNameForWanderer = Key<String>(
        "customizedNameForWanderer",
        default: .init(),
        suite: .baseSuite
    )

    /// 是否强制修复指定语言下的某些角色跟物品的名称用字。
    /// 该选项仅对中文介面可见。
    public static let forceCharacterWeaponNameFixed = Key<Bool>(
        "forceCharacterWeaponNameFixed",
        default: Pizza.isDebug,
        suite: .baseSuite
    )

    /// Whether displaying real names for certain characters, not affecting SRGF imports & exports.
    public static let useRealCharacterNames = Key<Bool>(
        "useRealCharacterNames",
        default: Pizza.isDebug,
        suite: .baseSuite
    )

    /// Default server for Genshin Daily Materials.
    public static let defaultServer = Key<String>(
        "defaultServer",
        default: "os_asia",
        suite: .baseSuite
    )
}

// MARK: - MainWidgetProvider

extension Defaults.Keys {
    public static let allWidgetsSyncFrequencyByMinutes = Key<Double>(
        "allWidgetsSyncFrequencyByMinutes",
        default: 6,
        suite: .baseSuite
    )

    public static let contentLegibilityShadowOpacity = Key<Double>(
        "contentLegibilityShadowOpacity",
        default: 0.7,
        suite: .baseSuite
    )
}

// MARK: - ResinRecoveryActivityController

extension Defaults.Keys {
    public static let autoDeliveryResinTimerLiveActivity = Key<Bool>(
        "autoDeliveryResinTimerLiveActivity",
        default: false,
        suite: .baseSuite
    )
    public static let resinRecoveryLiveActivityShowExpedition = Key<Bool>(
        "resinRecoveryLiveActivityShowExpedition",
        default: true,
        suite: .baseSuite
    )
    public static let autoUpdateResinRecoveryTimerUsingReFetchData =
        Key<Bool>("autoUpdateResinRecoveryTimerUsingReFetchData", default: true, suite: .baseSuite)
    public static let resinRecoveryLiveActivityUseEmptyBackground =
        Key<Bool>("resinRecoveryLiveActivityUseEmptyBackground", default: false, suite: .baseSuite)
    public static let resinRecoveryLiveActivityUseCustomizeBackground =
        Key<Bool>("resinRecoveryLiveActivityUseCustomizeBackground", default: false, suite: .baseSuite)
}
