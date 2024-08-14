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
    public static let appLanguage = Key<[String]?>(AppLanguage.defaultsKeyName, default: nil, suite: .standard)
    /// Remembering the most-recent tab index.
    public static let appTabIndex = Key<Int>("appTabIndex", default: 0, suite: .baseSuite)
    /// Remembering the most-recent tab index.
    public static let restoreTabOnLaunching = Key<Bool>("restoreTabOnLaunching", default: true, suite: .baseSuite)
}
