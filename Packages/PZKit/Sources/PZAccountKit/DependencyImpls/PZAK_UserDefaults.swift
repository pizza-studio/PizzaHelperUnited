// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
extension UserDefaults {
    public static let profileSuite = UserDefaults.baseSuite
}

extension Defaults.Keys {
    public static let oldAccountMOAlreadyAutoInherited = Key<Bool>(
        "oldAccountMOAlreadyAutoInherited",
        default: !Pizza.isAppStoreRelease,
        suite: Defaults[.situatePZProfileDBIntoGroupContainer] ? .standard : .baseSuite
    )
    public static let lastTimeResetLocalProfileDB = Key<Date?>(
        "lastTimeResetLocalProfileDB",
        default: nil,
        suite: Defaults[.situatePZProfileDBIntoGroupContainer] ? .standard : .baseSuite
    )
    public static let situatePZProfileDBIntoGroupContainer = Key<Bool>(
        "situatePZProfileDBIntoGroupContainer",
        default: true,
        suite: .standard
    )
    public static let automaticallyDeduplicatePZProfiles = Key<Bool>(
        "automaticallyDeduplicatePZProfiles",
        default: true,
        suite: .standard
    )
    public static let recentlyPropagatedDeviceFingerprint = Key<String>(
        "recentlyPropagatedDeviceFingerprint",
        default: "",
        suite: .standard
    )
    public static let pzProfiles = Key<[String: PZProfileSendable]>(
        "pzProfiles",
        default: [:],
        suite: .profileSuite // !! IMPORTANT !!
    )
    /// 各 profile 最近一次接受本地修改的时间戳 (timeIntervalSince1970) 影子表，
    /// 键为 profile 的 uuid.uuidString。用于裁决 CloudKit 导入的过期资料。
    public static let pzProfilesLastLocalEditTimestamps = Key<[String: Int64]>(
        "pzProfilesLastLocalEditTimestamps",
        default: [:],
        suite: .profileSuite // !! IMPORTANT !!
    )
    public static let cachedDailyNotes = Key<[String: CachedJSON]>(
        "cachedDailyNotes",
        default: [:],
        suite: .profileSuite // !! IMPORTANT !!
    )
}

// MARK: - PZProfileSendable + Defaults.Serializable

extension PZProfileSendable: Defaults.Serializable {}
