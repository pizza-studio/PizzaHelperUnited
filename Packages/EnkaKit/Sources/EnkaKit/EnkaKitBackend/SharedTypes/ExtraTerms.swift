// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - Enka.ExtraTerms

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public struct ExtraTerms: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(lang: String = Enka.currentLangTag, game: GameType) {
            let lang = Enka.sanitizeLangTag(lang)
            let table = Enka.JSONType.bundledExtraLangTable[lang]
            self.langTag = lang
            let keys = game.i18nKeyForExtraTerms
            self.levelName = table?[keys.levelName] ?? "Lv."
            self.levelNameShortened = table?[keys.levelNameShortened] ?? "Lv."
            self.constellationName = table?[keys.constellationName] ?? "Cons."
            self.artifactRatingName = table?[keys.artifactRatingName] ?? "Artifact Compatibility"
            self.artifactRatingUnit = table?[keys.artifactRatingUnit] ?? "pt"
            self.trailblazeLevel = table?[keys.trailblazeLevel] ?? "Adventure Rank"
            self.trailblazeLevelShortened = table?[keys.trailblazeLevelShortened] ?? "AR."
            self.equilibriumLevel = table?[keys.equilibriumLevel] ?? "World Level"
            self.equilibriumLevelShortened = table?[keys.equilibriumLevelShortened] ?? "WL."
        }

        fileprivate init(
            langTag: String,
            levelName: String,
            levelNameShortened: String,
            constellationName: String,
            artifactRatingName: String,
            artifactRatingUnit: String,
            trailblazeLevel: String,
            trailblazeLevelShortened: String,
            equilibriumLevel: String,
            equilibriumLevelShortened: String
        ) {
            self.langTag = langTag
            self.levelName = levelName
            self.levelNameShortened = levelNameShortened
            self.constellationName = constellationName
            self.artifactRatingName = artifactRatingName
            self.artifactRatingUnit = artifactRatingUnit
            self.trailblazeLevel = trailblazeLevel
            self.trailblazeLevelShortened = trailblazeLevelShortened
            self.equilibriumLevel = equilibriumLevel
            self.equilibriumLevelShortened = equilibriumLevelShortened
        }

        // MARK: Public

        public let langTag: String
        public let levelName: String
        public let levelNameShortened: String
        public let constellationName: String
        public let artifactRatingName: String
        public let artifactRatingUnit: String
        public let trailblazeLevel: String
        public let trailblazeLevelShortened: String
        public let equilibriumLevel: String
        public let equilibriumLevelShortened: String
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.GameType {
    var i18nKeyForExtraTerms: Enka.ExtraTerms {
        switch self {
        case .genshinImpact:
            .init(
                langTag: Enka.currentLangTag,
                levelName: "_AvatarLevel",
                levelNameShortened: "_AvatarLevelShortened",
                constellationName: "_Constellation",
                artifactRatingName: "_ArtifactRating",
                artifactRatingUnit: "_UnitForPoints",
                trailblazeLevel: "_AdventureRank",
                trailblazeLevelShortened: "_AdventureRankShortened",
                equilibriumLevel: "_WorldLevel",
                equilibriumLevelShortened: "_WorldLevelShortened"
            )
        case .starRail:
            .init(
                langTag: Enka.currentLangTag,
                levelName: "_AvatarLevel",
                levelNameShortened: "_AvatarLevelShortened",
                constellationName: "_EidolonResonance",
                artifactRatingName: "_ArtifactRating",
                artifactRatingUnit: "_UnitForPoints",
                trailblazeLevel: "_TrailblazeLevel",
                trailblazeLevelShortened: "_TrailblazeLevelShortened",
                equilibriumLevel: "_EquilibriumLevel",
                equilibriumLevelShortened: "_EquilibriumLevelShortened"
            )
        case .zenlessZone: // 临时设定。
            .init(
                langTag: Enka.currentLangTag,
                levelName: "_AvatarLevel",
                levelNameShortened: "_AvatarLevelShortened",
                constellationName: "_Constellation",
                artifactRatingName: "_ArtifactRating",
                artifactRatingUnit: "_UnitForPoints",
                trailblazeLevel: "_AdventureRank",
                trailblazeLevelShortened: "_AdventureRankShortened",
                equilibriumLevel: "_WorldLevel",
                equilibriumLevelShortened: "_WorldLevelShortened"
            )
        }
    }
}
