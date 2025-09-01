// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import enum EnkaDBModels.EnkaDBModelsGI
import Foundation
import Observation
import PZBaseKit

// MARK: - Enka.EnkaDB4GI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    @Observable
    public final class EnkaDB4GI: EnkaDBProtocol, Codable, @unchecked Sendable {
        // MARK: Lifecycle

        required public convenience init(host: Enka.HostType) async throws {
            try await self.init(
                locTag: Enka.currentLangTag,
                locTables: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .giLocTable,
                    decodingTo: Enka.RawLocTables.self
                ),
                characters: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .giCharacters,
                    decodingTo: EnkaDBModelsGI.CharacterDict.self
                ),
                namecards: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .giNamecards,
                    decodingTo: EnkaDBModelsGI.NameCardDict.self
                ),
                profilePictures: Enka.Sputnik.fetchEnkaDBData(
                    from: host, type: .giProfileAvatarIcons,
                    decodingTo: EnkaDBModelsGI.ProfilePictureDict.self
                )
            )
        }

        public init(
            locTag: String? = nil,
            locTables: Enka.RawLocTables,
            characters: EnkaDBModelsGI.CharacterDict,
            namecards: EnkaDBModelsGI.NameCardDict,
            profilePictures: EnkaDBModelsGI.ProfilePictureDict
        ) throws {
            let locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
            guard let locTableSpecified = locTables[locTag] else {
                throw Enka.EKError.langTableMatchingFailure
            }
            self.locTag = locTag
            self.locTable = locTableSpecified
            self.characters = characters
            self.namecards = namecards
            self.profilePictures = profilePictures
        }

        public init(
            locTag: String? = nil,
            locTable: Enka.LocTable,
            characters: EnkaDBModelsGI.CharacterDict,
            namecards: EnkaDBModelsGI.NameCardDict,
            profilePictures: EnkaDBModelsGI.ProfilePictureDict
        ) {
            self.locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
            self.locTable = locTable
            self.characters = characters
            self.namecards = namecards
            self.profilePictures = profilePictures
        }

        // MARK: Public

        public typealias QueriedResult = Enka.QueriedResultGI
        public typealias QueriedProfile = Enka.QueriedProfileGI
        public typealias HYLAvatarDetailType = HYQueriedModels.HYLAvatarDetail4GI

        @MainActor public static var shared: Enka.EnkaDB4GI { Enka.Sputnik.shared.db4GI }

        public var locTag: String
        public var locTable: Enka.LocTable
        public var characters: EnkaDBModelsGI.CharacterDict
        public var namecards: EnkaDBModelsGI.NameCardDict
        public var profilePictures: EnkaDBModelsGI.ProfilePictureDict
        public var isExpired: Bool = false

        @MainActor
        public func saveSelfToUserDefaults() {
            Enka.Sputnik.shared.db4GI = self
        }

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case _locTag
            case _locTable
            case _characters
            case _namecards
            case _profilePictures
            case _isExpired
        }
    }
}

// MARK: - Protocol Conformance.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4GI {
    public static var game: Enka.GameType { .genshinImpact }

    /// Only available for characters.
    public func getNameTextMapHash(id: String) -> String? {
        let matchedInts: [UInt] = characters.compactMap {
            guard $0.key.hasPrefix(id) else { return nil }
            return $0.value.nameTextMapHash
        }
        return matchedInts.first?.description
    }

    @MainActor
    public func update(new: Enka.EnkaDB4GI) {
        locTag = new.locTag
        locTable = new.locTable
        characters = new.characters
        namecards = new.namecards
        profilePictures = new.profilePictures
        isExpired = false
        saveSelfToUserDefaults()
    }
}

// MARK: - Use bundled resources to initiate an EnkaDB instance.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4GI {
    public convenience init(locTag: String? = nil) throws {
        let locTables = try Enka.JSONType.giLocTable.bundledJSONData
            .assertedParseAs(Enka.RawLocTables.self)
        let locTag = Enka.sanitizeLangTag(locTag ?? Enka.currentLangTag)
        guard let locTableSpecified = locTables[locTag] else {
            throw Enka.EKError.langTableMatchingFailure
        }
        self.init(
            locTag: locTag,
            locTable: locTableSpecified,
            characters: try Enka.JSONType.giCharacters.bundledJSONData
                .assertedParseAs(EnkaDBModelsGI.CharacterDict.self),
            namecards: try Enka.JSONType.giNamecards.bundledJSONData
                .assertedParseAs(EnkaDBModelsGI.NameCardDict.self),
            profilePictures: try Enka.JSONType.giProfileAvatarIcons.bundledJSONData
                .assertedParseAs(EnkaDBModelsGI.ProfilePictureDict.self)
        )
    }
}

// MARK: - Expiry Check.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4GI {
    public func checkIfExpired(against givenProfile: QueriedProfile) -> Bool {
        guard Enka.currentLangTag == locTag else { return true }
        // 与星穹铁道不同，除了角色以外的内容在 EnkaDB 里面没有现成的 ID 库可以查询。
        // 好在可以用来查询对应的 NameTextMapHash。
        // 先检查角色 ID：
        let newAvatarIDs = Set<String>(givenProfile.avatarDetailList.map(\.id))
        let remainingIDs = newAvatarIDs.subtracting(characters.keys)
        guard remainingIDs.isEmpty else { return true }
        // 再检查武器，用验证 NameTextMapHash 的方式。
        var newEquipNameHashes: Set<String> = .init(
            givenProfile.avatarDetailList.map {
                $0.equipList.compactMap { equip in
                    equip.flat.equipType == nil ? equip.flat.nameTextMapHash : nil
                }
            }.reduce([], +)
        )
        // 同时检查圣遗物，用圣遗物套装名称 setNameTextMapHash 检查。
        givenProfile.avatarDetailList.map {
            $0.equipList.compactMap(\.flat.setNameTextMapHash)
        }.reduce([], +).forEach {
            newEquipNameHashes.insert($0)
        }
        let remainingHashes = newEquipNameHashes.subtracting(locTable.keys)
        return !remainingHashes.isEmpty
    }
}

// MARK: - Extra.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.EnkaDB4GI {
    public func findCostume(charID: String) -> (costumeID: String, costume: EnkaDBModelsGI.Costume)? {
        guard let matchedCharacter = characters[charID] else { return nil }
        let filtered: [(String, EnkaDBModelsGI.Costume)]? = matchedCharacter.costumes?.filter {
            !$0.value.sideIconName.contains("CostumeWic")
        }
        return filtered?.first
    }
}
