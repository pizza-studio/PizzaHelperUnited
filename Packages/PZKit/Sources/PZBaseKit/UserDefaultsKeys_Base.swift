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
    /// App UI language. At least, this works with macOS. This must use the standard container.
    public static let appLanguage = Key<[String]?>(
        AppLanguage.defaultsKeyName,
        default: nil,
        suite: .standard
    )

    /// Remembering the most-recent tab index.
    public static let appTabIndex = Key<Int>(
        "appTabIndex",
        default: 0,
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
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying real names for certain characters, not affecting SRGF imports & exports.
    public static let useRealCharacterNames = Key<Bool>(
        "useRealCharacterNames",
        default: true,
        suite: .baseSuite
    )
}
