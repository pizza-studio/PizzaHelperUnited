// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
@preconcurrency import Foundation
import PZBaseKit

extension UserDefaults {
    public static let profileSuite = UserDefaults.baseSuite
}

extension Defaults.Keys {
    public static let oldAccountMOAlreadyAutoInherited = Key<Bool>(
        "oldAccountMOAlreadyAutoInherited",
        default: !Pizza.isAppStoreRelease,
        suite: .baseSuite
    )
    public static let lastTimeResetLocalProfileDB = Key<Date?>(
        "lastTimeResetLocalProfileDB",
        default: nil,
        suite: .baseSuite
    )
    public static let pzProfiles = Key<[String: PZProfileSendable]>(
        "pzProfiles",
        default: [:],
        suite: .profileSuite // !! IMPORTANT !!
    )
}

// MARK: - PZProfileSendable + _DefaultsSerializable

extension PZProfileSendable: _DefaultsSerializable {}
