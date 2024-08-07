// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import enum EnkaDBModels.EnkaDBModelsGI
import Foundation

// MARK: - Enka.EnkaDB4GI

extension Enka {
    @Observable
    public class EnkaDB4GI: EnkaDBProtocol, Codable {
        // MARK: Lifecycle

        public init(
            locTag: String? = nil,
            locTable: Enka.LocTable,
            characters: EnkaDBModelsGI.CharacterDict,
            namecards: EnkaDBModelsGI.NameCardDict,
            profilePictures: EnkaDBModelsGI.ProfilePictureDict
        ) {
            self.locTag = Enka.sanitizeLangTag(locTag ?? Locale.langCodeForEnkaAPI)
            self.locTable = locTable
            self.characters = characters
            self.namecards = namecards
            self.profilePictures = profilePictures
        }

        // MARK: Public

        public var locTag: String
        public var locTable: Enka.LocTable
        public var characters: EnkaDBModelsGI.CharacterDict
        public var namecards: EnkaDBModelsGI.NameCardDict
        public var profilePictures: EnkaDBModelsGI.ProfilePictureDict
        public var isExpired: Bool = false

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

extension Enka.EnkaDB4GI {
    public var game: Enka.HoyoGame { .genshinImpact }

    /// Only available for characters.
    public func getNameTextMapHash(id: String) -> String? {
        var result = String?.none
        var matchedInts: [Int] = characters.compactMap {
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
    }
}
