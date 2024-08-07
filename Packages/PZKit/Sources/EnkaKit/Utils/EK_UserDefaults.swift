// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

extension UserDefaults {
    public static let enkaSuite = UserDefaults(suiteName: appGroupID + ".storageForEnka") ?? .baseSuite
}

extension Defaults.Keys {
    // MARK: - Enka Suite

    public static let lastEnkaDBDataCheckDate = Key<Date>(
        "lastEnkaDBDataCheckDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .enkaSuite
    )
    public static let enkaDBData4GI = Key<Enka.EnkaDB4GI>(
        "enkaDBData4GI",
        default: try! Enka.EnkaDB4GI(locTag: Locale.langCodeForEnkaAPI),
        suite: .enkaSuite
    )
    public static let enkaDBData4HSR = Key<Enka.EnkaDB4HSR>(
        "enkaDBData4HSR",
        default: try! Enka.EnkaDB4HSR(locTag: Locale.langCodeForEnkaAPI),
        suite: .enkaSuite
    )
    public static let defaultDBQueryHost = Key<Enka.HostType>(
        "defaultDBQueryHost",
        default: Enka.HostType.enkaGlobal,
        suite: .enkaSuite
    )

    // MARK: - HSR Suite

    /// Whether animating on calling character showcase panel tabView.
    public static let animateOnCallingCharacterShowcase = Key<Bool>(
        "animateOnCallingCharacterShowcase",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying character photos in Genshin style.
    public static let useGenshinStyleCharacterPhotos = Key<Bool>(
        "useGenshinStyleCharacterPhotos",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying artifact compatibility rating results in EachAvatarStatView.
    public static let enableArtifactRatingInShowcase = Key<Bool>(
        "enableArtifactRatingInShowcase",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying real names for certain characters, not affecting SRGF imports & exports.
    public static let useRealCharacterNames = Key<Bool>(
        "useRealCharacterNames",
        default: false,
        suite: .baseSuite
    )
}

// MARK: - Enka.EnkaDB4GI + _DefaultsSerializable

extension Enka.EnkaDB4GI: _DefaultsSerializable {}

// MARK: - Enka.EnkaDB4HSR + _DefaultsSerializable

extension Enka.EnkaDB4HSR: _DefaultsSerializable {}

// MARK: - Enka.HostType + _DefaultsSerializable

extension Enka.HostType: _DefaultsSerializable {
    public static func toggleEnkaDBQueryHost() {
        switch Defaults[.defaultDBQueryHost] {
        case .enkaGlobal: Defaults[.defaultDBQueryHost] = .mainlandChina
        case .mainlandChina: Defaults[.defaultDBQueryHost] = .enkaGlobal
        }
    }
}
