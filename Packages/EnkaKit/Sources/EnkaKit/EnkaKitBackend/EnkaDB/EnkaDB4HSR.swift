// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import enum EnkaDBModels.EnkaDBModelsHSR
import Foundation
import Observation
import PZBaseKit

// MARK: - Enka.EnkaDB4HSR

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka {
    @Observable
    public final class EnkaDB4HSR: EnkaDBProtocol, Codable, @unchecked Sendable {
        // MARK: Lifecycle

        required public convenience init(host: Enka.HostType) async throws {
            try await self.init(
                locTag: Enka.currentLangTag,
                locTables: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrLocTable,
                    decodingTo: Enka.RawLocTables.self
                ),
                profileAvatars: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrProfileAvatarIcons,
                    decodingTo: EnkaDBModelsHSR.ProfileAvatarDict.self
                ),
                characters: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrCharacters,
                    decodingTo: EnkaDBModelsHSR.CharacterDict.self
                ),
                meta: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrMetadata,
                    decodingTo: EnkaDBModelsHSR.Meta.self
                ),
                skillRanks: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrSkillRanks,
                    decodingTo: EnkaDBModelsHSR.SkillRanksDict.self
                ),
                artifacts: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrArtifacts,
                    decodingTo: EnkaDBModelsHSR.ArtifactsDict.self
                ),
                skills: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrSkills,
                    decodingTo: EnkaDBModelsHSR.SkillsDict.self
                ),
                skillTrees: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrSkillTrees,
                    decodingTo: EnkaDBModelsHSR.SkillTreesDict.self
                ),
                weapons: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .hsrWeapons,
                    decodingTo: EnkaDBModelsHSR.WeaponsDict.self
                )
            )
        }

        public init(
            locTag: String? = nil,
            locTables: Enka.RawLocTables,
            profileAvatars: EnkaDBModelsHSR.ProfileAvatarDict,
            characters: EnkaDBModelsHSR.CharacterDict,
            meta: EnkaDBModelsHSR.Meta,
            skillRanks: EnkaDBModelsHSR.SkillRanksDict,
            artifacts: EnkaDBModelsHSR.ArtifactsDict,
            skills: EnkaDBModelsHSR.SkillsDict,
            skillTrees: EnkaDBModelsHSR.SkillTreesDict,
            weapons: EnkaDBModelsHSR.WeaponsDict
        ) throws {
            let locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
            guard let locTableSpecified = locTables[locTag] else {
                throw Enka.EKError.langTableMatchingFailure
            }
            self.locTag = locTag
            self.locTable = locTableSpecified
            self.profileAvatars = profileAvatars
            self.characters = characters
            self.meta = meta
            self.skillRanks = skillRanks
            self.artifacts = artifacts
            self.skills = skills
            self.skillTrees = skillTrees
            self.weapons = weapons
        }

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
            self.locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
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

        public typealias QueriedResult = Enka.QueriedResultHSR
        public typealias QueriedProfile = Enka.QueriedProfileHSR
        public typealias HYLAvatarDetailType = HYQueriedModels.HYLAvatarDetail4HSR

        @MainActor public static var shared: Enka.EnkaDB4HSR { Enka.Sputnik.shared.db4HSR }

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

        @MainActor
        public func saveSelfToUserDefaults() {
            Defaults[.enkaDBData4HSR] = self
        }

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case _locTag
            case _locTable
            case _profileAvatars
            case _characters
            case _meta
            case _skillRanks
            case _artifacts
            case _skills
            case _skillTrees
            case _weapons
            case _isExpired
        }
    }
}

// MARK: - Protocol Conformance.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.EnkaDB4HSR {
    public static var game: Enka.GameType { .starRail }

    /// Only available for characters and Weapons.
    public func getNameTextMapHash(id: String) -> String? {
        var matchedInts: [String] = characters.compactMap {
            guard $0.key.hasPrefix(id) else { return nil }
            return $0.value.avatarName.hash
        }
        matchedInts += weapons.compactMap {
            guard $0.key.hasPrefix(id) else { return nil }
            return $0.value.equipmentName.hash
        }
        return matchedInts.first
    }

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
        isExpired = false
    }
}

// MARK: - Use bundled resources to initiate an EnkaDB instance.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.EnkaDB4HSR {
    public convenience init(locTag: String? = nil) throws {
        let locTables = try Enka.JSONType.hsrLocTable.bundledJSONData
            .assertedParseAs(Enka.RawLocTables.self)
        let locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
        guard let locTableSpecified = locTables[locTag] else {
            throw Enka.EKError.langTableMatchingFailure
        }
        self.init(
            locTag: locTag,
            locTable: locTableSpecified,
            profileAvatars: try Enka.JSONType.hsrProfileAvatarIcons.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.ProfileAvatarDict.self),
            characters: try Enka.JSONType.hsrCharacters.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.CharacterDict.self),
            meta: try Enka.JSONType.hsrMetadata.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.Meta.self),
            skillRanks: try Enka.JSONType.hsrSkillRanks.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillRanksDict.self),
            artifacts: try Enka.JSONType.hsrArtifacts.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.ArtifactsDict.self),
            skills: try Enka.JSONType.hsrSkills.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillsDict.self),
            skillTrees: try Enka.JSONType.hsrSkillTrees.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.SkillTreesDict.self),
            weapons: try Enka.JSONType.hsrWeapons.bundledJSONData
                .assertedParseAs(EnkaDBModelsHSR.WeaponsDict.self)
        )
    }
}

// MARK: - Expiry Check.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.EnkaDB4HSR {
    public func checkIfExpired(against givenProfile: QueriedProfile) -> Bool {
        guard Enka.currentLangTag == locTag else { return true }
        // 星穹铁道直接拿角色、武器、圣遗物 ID 来查询就好。
        // 先检查角色 ID：
        var newIDs = Set<String>(givenProfile.avatarDetailList.map(\.id))
        var remainingIDs = newIDs.subtracting(characters.keys)
        guard remainingIDs.isEmpty else { return true }
        // 再检查武器：
        newIDs = Set<String>(
            givenProfile.avatarDetailList.compactMap(\.equipment?.tid.description)
        )
        remainingIDs = newIDs.subtracting(weapons.keys)
        guard remainingIDs.isEmpty else { return true }
        // 再检查圣遗物。
        newIDs = Set<String>(
            givenProfile.avatarDetailList.compactMap { avatar in
                avatar.relicList?.map(\.tid.description)
            }.reduce([], +)
        )
        remainingIDs = newIDs.subtracting(artifacts.keys)
        return !remainingIDs.isEmpty
    }
}
