// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

extension UserDefaults {
    public static let enkaSuite = UserDefaults(suiteName: appGroupID + ".storageForEnka") ??
        .baseSuite
}

extension Defaults.Keys {
    // MARK: - Enka Suite

    public static let lastEnkaDBDataCheckDate = Key<Date>(
        "lastEnkaDBDataCheckDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .enkaSuite
    )
    public static let defaultDBQueryHost = Key<Enka.HostType>(
        "defaultDBQueryHost",
        default: Enka.HostType.enkaGlobal,
        suite: .enkaSuite
    )
    public static let artifactRatingDB = Key<ArtifactRating.ModelDB>(
        "artifactRatingDB",
        default: .makeBundledDB(),
        suite: .enkaSuite
    )
    public static let artifactCountDB4GI = Key<[String: Enka.PropertyType]>(
        "artifactCountDB4GI",
        default: ArtifactRating.initBundledCountDB(),
        suite: .enkaSuite
    )
    public static let enkaDBData4GI = Key<Enka.EnkaDB4GI>(
        "enkaDBData4GI",
        default: try! Enka.EnkaDB4GI(locTag: Enka.currentLangTag),
        suite: .enkaSuite
    )
    public static let enkaDBData4HSR = Key<Enka.EnkaDB4HSR>(
        "enkaDBData4HSR",
        default: try! Enka.EnkaDB4HSR(locTag: Enka.currentLangTag),
        suite: .enkaSuite
    )
    public static let queriedEnkaProfiles4GI = Key<[String: Enka.QueriedProfileGI]>(
        "queriedEnkaProfiles4GI",
        default: [:],
        suite: .enkaSuite
    )
    public static let queriedEnkaProfiles4HSR = Key<[String: Enka.QueriedProfileHSR]>(
        "queriedEnkaProfiles4HSR",
        default: [:],
        suite: .enkaSuite
    )
    public static let queriedHoYoProfiles4GI = Key<[String: [HYQueriedModels.HYLAvatarDetail4GI]]>(
        "queriedHoYoProfiles4GI",
        default: [:],
        suite: .enkaSuite
    )
    public static let queriedHoYoProfiles4HSR = Key<[String: [HYQueriedModels.HYLAvatarDetail4HSR]]>(
        "queriedHoYoProfiles4HSR",
        default: [:],
        suite: .enkaSuite
    )

    // MARK: - Base Suite

    /// 决定是否给原神的角色证件照启用图腾。
    public static let useTotemWithGenshinIDPhotos = Key<Bool>(
        "useTotemWithGenshinIDPhotos",
        default: true,
        suite: .baseSuite
    )

    /// 决定是否给原神的角色面板与证件照启用名片背景。
    public static let useNameCardBGWithGICharacters = Key<Bool>(
        "useNameCardBGWithGICharacters",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying Star Rail character photos in Genshin style.
    public static let useGenshinStyleCharacterPhotos = Key<Bool>(
        "useGenshinStyleCharacterPhotos",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying artifact sub-props in different colors to indicate their steps.
    public static let colorizeArtifactSubPropCounts = Key<Bool>(
        "colorizeArtifactSubPropCounts",
        default: true,
        suite: .baseSuite
    )

    /// Artifact rating preferences for Genshin Impact.
    public static let artifactRatingRules = Key<ArtifactRating.Rules>(
        "artifactRatingRules",
        default: .allEnabled,
        suite: .baseSuite
    )
}

// MARK: - ArtifactRating.Rules + Defaults.Serializable

extension ArtifactRating.Rules: Defaults.Serializable {}

// MARK: - ArtifactRating.RatingModel + Defaults.Serializable

extension ArtifactRating.RatingModel: Defaults.Serializable {}

// MARK: - Enka.EnkaDB4GI + Defaults.Serializable

extension Enka.EnkaDB4GI: Defaults.Serializable {}

// MARK: - Enka.EnkaDB4HSR + Defaults.Serializable

extension Enka.EnkaDB4HSR: Defaults.Serializable {}

// MARK: - Enka.QueriedProfileGI + Defaults.Serializable

extension Enka.QueriedProfileGI: Defaults.Serializable {}

// MARK: - Enka.QueriedProfileHSR + Defaults.Serializable

extension Enka.QueriedProfileHSR: Defaults.Serializable {}

// MARK: - Enka.PropertyType + Defaults.Serializable

extension Enka.PropertyType: Defaults.Serializable {}

// MARK: - Enka.HostType + Defaults.Serializable

extension Enka.HostType: Defaults.Serializable {
    public static func toggleEnkaDBQueryHost() {
        switch Defaults[.defaultDBQueryHost] {
        case .enkaGlobal: Defaults[.defaultDBQueryHost] = .mainlandChina
        case .mainlandChina: Defaults[.defaultDBQueryHost] = .enkaGlobal
        }
    }
}

// MARK: - HYQueriedModels.HYLAvatarDetail4GI + Defaults.Serializable

extension HYQueriedModels.HYLAvatarDetail4GI: Defaults.Serializable {}

// MARK: - HYQueriedModels.HYLAvatarDetail4HSR + Defaults.Serializable

extension HYQueriedModels.HYLAvatarDetail4HSR: Defaults.Serializable {}
