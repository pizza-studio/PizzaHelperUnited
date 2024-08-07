// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBFiles
import Foundation

extension Enka {
    public enum JSONType: String, CaseIterable {
        case giLocTable = "locs"
        case giCharacters = "characters"
        case giNamecards = "namecards"
        case giProfileAvatarIcons = "pfps" // Player Account Profile Picture
        case hsrLocTable = "hsr"
        case hsrProfileAvatarIcons = "honker_avatars" // Player Account Profile Picture
        case hsrCharacters = "honker_characters"
        case hsrMetadata = "honker_meta"
        case hsrSkillRanks = "honker_ranks"
        case hsrArtifacts = "honker_relics"
        case hsrSkillTrees = "honker_skilltree"
        case hsrSkills = "honker_skills"
        case hsrWeapons = "honker_weps"
        case hsrRealNameTable = "RealNameDict"
        case retrieved = "N/A" // The JSON file retrieved from Enka Networks website per each query.

        // MARK: Public

        // Bundle JSON Accessor.
        public static var bundledExtraLangTable: Enka.RawLocTables = {
            guard let url = Bundle.module.url(
                forResource: "AdditionalLangTableShared", withExtension: "json"
            ) else { return [:] }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([String: [String: String]].self, from: data)
            } catch {
                NSLog("EnkaKit: Cannot access bundledExtraLangTable.json.")
                return [:]
            }
        }()

        // Bundle JSON Accessor.
        public static var bundledRealNameTable: Enka.RawLocTables = {
            guard let url = Bundle.module.url(
                forResource: "RealNameDict", withExtension: "json"
            ) else { return [:] }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([String: [String: String]].self, from: data)
            } catch {
                NSLog("EnkaKit: Cannot access RealNameDict.json.")
                return [:]
            }
        }()

        // Bundle JSON Accessor.
        public var bundledJSONData: Data? {
            guard rawValue != "N/A" else { return nil }
            return EnkaDBFileProvider.getBundledJSONFileData(fileNameStem: rawValue)
        }

        public func getBundledJSONObject<T: Decodable>(
            as: T.Type, decoderConfigurator: ((JSONDecoder) -> Void)? = nil
        )
            -> T? {
            guard rawValue != "N/A" else { return nil }
            return EnkaDBFileProvider.getBundledJSONFileObject(
                fileNameStem: rawValue,
                type: T.self,
                decoderConfigurator: decoderConfigurator
            )
        }
    }
}
