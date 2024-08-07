// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import enum EnkaDBModels.EnkaDBModelsHSR
import Foundation

// MARK: - Enka.EnkaDB4HSR

extension Enka {
    @Observable
    public class EnkaDB4HSR: EnkaDBProtocol, Codable {
        // MARK: Lifecycle

        public init(
            locTag: String? = nil,
            locTable: Enka.LocTable,
            profileAvatars: EnkaDBModelsHSR.ProfileAvatarDict,
            characters: EnkaDBModelsHSR.CharacterDict,
            meta: EnkaDBModelsHSR.Meta,
            skillRanks: EnkaDBModelsHSR.SkillRanksDict,
            artifacts: EnkaDBModelsHSR.ArtifactsDict,
            skills: EnkaDBModelsHSR.SkillsDict,
            skillTrees: EnkaDBModelsHSR.SkillTreesDict,
            weapons: EnkaDBModelsHSR.WeaponsDict
        ) {
            self.locTag = Enka.sanitizeLangTag(locTag ?? Locale.langCodeForEnkaAPI)
            self.locTable = locTable
            self.profileAvatars = profileAvatars
            self.characters = characters
            self.meta = meta
            self.skillRanks = skillRanks
            self.artifacts = artifacts
            self.skills = skills
            self.skillTrees = skillTrees
            self.weapons = weapons
        }

        // MARK: Public

        public var locTag: String
        public var locTable: Enka.LocTable
        public var profileAvatars: EnkaDBModelsHSR.ProfileAvatarDict
        public var characters: EnkaDBModelsHSR.CharacterDict
        public var meta: EnkaDBModelsHSR.Meta
        public var skillRanks: EnkaDBModelsHSR.SkillRanksDict
        public var artifacts: EnkaDBModelsHSR.ArtifactsDict
        public var skills: EnkaDBModelsHSR.SkillsDict
        public var skillTrees: EnkaDBModelsHSR.SkillTreesDict
        public var weapons: EnkaDBModelsHSR.WeaponsDict
        public var isExpired: Bool = false
    }
}

extension Enka.EnkaDB4HSR {
    public var game: Enka.HoyoGame { .starRail }

    @MainActor
    public func update(new: Enka.EnkaDB4HSR) {
        locTag = new.locTag
        locTable = new.locTable
        profileAvatars = new.profileAvatars
        characters = new.characters
        meta = new.meta
        skillRanks = new.skillRanks
        artifacts = new.artifacts
        skills = new.skills
        skillTrees = new.skillTrees
        weapons = new.weapons
    }
}
