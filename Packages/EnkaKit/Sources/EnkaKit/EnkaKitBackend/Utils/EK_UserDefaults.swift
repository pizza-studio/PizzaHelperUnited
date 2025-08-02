// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Defaults
import Foundation
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, *)
extension UserDefaults {
    public static let enkaSuite: UserDefaults = {
        let result = UserDefaults(suiteName: appGroupID + ".storageForEnka") ??
            .baseSuite
        // HoYoLAB 的角色面板资料档案异常庞大，于是这里不再用 UserDefaults 处理。
        result.removeObject(forKey: "queriedHoYoProfiles4GI")
        result.removeObject(forKey: "queriedHoYoProfiles4HSR")
        // Enka Networks 的角色面板资料也不再用 UserDefaults 处理，但這裡先做遷移。
        return result
    }()
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.Sputnik {
    public static func migrateCachedProfilesFromUserDefaultsToFiles() {
        let oldEnkaProfiles4GI = Defaults[.queriedEnkaProfiles4GI]
        if !oldEnkaProfiles4GI.isEmpty {
            oldEnkaProfiles4GI.values.forEach { $0.saveToCache() }
            Defaults.reset(.queriedEnkaProfiles4GI)
        }
        let oldEnkaProfiles4HSR = Defaults[.queriedEnkaProfiles4HSR]
        if !oldEnkaProfiles4HSR.isEmpty {
            oldEnkaProfiles4HSR.values.forEach { $0.saveToCache() }
            Defaults.reset(.queriedEnkaProfiles4HSR)
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
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

    // MARK: - Enka Suite (Deprecated APIs kept for data migration purposes.)

    fileprivate static let queriedEnkaProfiles4GI = Key<[String: Enka.QueriedProfileGI]>(
        "queriedEnkaProfiles4GI",
        default: [:],
        suite: .enkaSuite
    )
    fileprivate static let queriedEnkaProfiles4HSR = Key<[String: Enka.QueriedProfileHSR]>(
        "queriedEnkaProfiles4HSR",
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.Rules: Defaults.Serializable {}

// MARK: - ArtifactRating.RatingModel + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.RatingModel: Defaults.Serializable {}

// MARK: - Enka.EnkaDB4GI + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4GI: Defaults.Serializable {}

// MARK: - Enka.EnkaDB4HSR + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4HSR: Defaults.Serializable {}

// MARK: - Enka.QueriedProfileGI + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.QueriedProfileGI: Defaults.Serializable {}

// MARK: - Enka.QueriedProfileHSR + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.QueriedProfileHSR: Defaults.Serializable {}

// MARK: - Enka.PropertyType + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.PropertyType: Defaults.Serializable {}

// MARK: - Enka.HostType + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.HostType: Defaults.Serializable {
    public static func toggleEnkaDBQueryHost() {
        switch Defaults[.defaultDBQueryHost] {
        case .enkaGlobal: Defaults[.defaultDBQueryHost] = .mainlandChina
        case .mainlandChina: Defaults[.defaultDBQueryHost] = .enkaGlobal
        }
    }
}

// MARK: - HYQueriedModels.HYLAvatarDetail4GI + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels.HYLAvatarDetail4GI: Defaults.Serializable {}

// MARK: - HYQueriedModels.HYLAvatarDetail4HSR + Defaults.Serializable

@available(iOS 17.0, macCatalyst 17.0, *)
extension HYQueriedModels.HYLAvatarDetail4HSR: Defaults.Serializable {}
