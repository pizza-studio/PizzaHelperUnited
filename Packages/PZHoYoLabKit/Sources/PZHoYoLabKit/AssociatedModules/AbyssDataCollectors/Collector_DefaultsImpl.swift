// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

extension UserDefaults {
    // 此处的 suiteName 得与 container ID 一致。
    public static let logSuite = UserDefaults(suiteName: "\(appGroupID).logs") ?? .standard
}

extension Defaults.Keys {
    public static let allowAbyssDataCollection = Key<Bool>(
        "allowAbyssDataCollection",
        default: false,
        suite: .baseSuite
    )
    public static let hasUploadedAvatarHoldingDataMD5 = Key<[String]>(
        "hasUploadedAvatarHoldingDataMD5",
        default: .init(),
        suite: .logSuite
    )
    public static let hasUploadedPZAbyssReportMD5 = Key<[String]>(
        "hasUploadedPZAbyssReportMD5",
        default: .init(),
        suite: .logSuite
    )
    public static let hasUploadedHutaoAbyssReportMD5 = Key<[String]>(
        "hasUploadedHutaoAbyssReportMD5",
        default: .init(),
        suite: .logSuite
    )
}
