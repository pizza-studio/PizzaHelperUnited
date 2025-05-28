// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
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
    public static let cachedDailyNotes = Key<[String: CachedJSON]>(
        "cachedDailyNotes",
        default: [:],
        suite: .profileSuite // !! IMPORTANT !!
    )
}

// MARK: - PZProfileSendable + Defaults.Serializable

extension PZProfileSendable: Defaults.Serializable {}
