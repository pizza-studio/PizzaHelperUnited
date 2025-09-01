// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import GachaMetaDB
import PZBaseKit
@available(iOS 17.0, macCatalyst 17.0, *)
extension UserDefaults {
    public static let gmdbSuite = UserDefaults(suiteName: appGroupID + ".storageForGMDB") ??
        .baseSuite
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Defaults.Keys {
    public static let lastGMDBDataCheckDate = Key<Date>(
        "lastCheckDateForGachaMetaDB",
        default: .init(timeIntervalSince1970: 0),
        suite: .gmdbSuite
    )
    /// 针对 UIGF v2.3 及之前版本的文件导入时所使用的垫底时区，预设值为 nil。
    public static let fallbackTimeForGIGFFileImport = Key<TimeZone?>(
        "fallbackTimeForGIGFFileImport",
        default: nil,
        suite: .gmdbSuite
    )
}

#if hasFeature(RetroactiveAttribute)
@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaItemMetadata: @retroactive Defaults.Serializable {}
@available(iOS 17.0, macCatalyst 17.0, *)
extension TimeZone: @retroactive Defaults.Serializable {}
#else
@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaItemMetadata: Defaults.Serializable {}
@available(iOS 17.0, macCatalyst 17.0, *)
extension TimeZone: Defaults.Serializable {}
#endif
