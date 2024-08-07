// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

extension UserDefaults {
    // 此处的 suiteName 得与 container ID 一致。
    public static let baseSuite = UserDefaults(suiteName: appGroupID) ?? .standard
}

extension Defaults.Keys {}
