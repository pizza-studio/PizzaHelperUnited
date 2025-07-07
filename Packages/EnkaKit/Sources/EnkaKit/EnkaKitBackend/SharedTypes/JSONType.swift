// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBFiles
import Foundation

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public enum JSONType: String, CaseIterable, Sendable {
        case giLocTable = "loc"
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

        // MARK: Public

        public var game: Enka.GameType {
            switch self {
            case .giCharacters, .giLocTable, .giNamecards, .giProfileAvatarIcons:
                .genshinImpact
            default: .starRail
            }
        }

        public var repoFileInternalPath: String {
            let rootFolder = "Sources/EnkaDBFiles/Resources/Specimen/"
            switch game {
            case .genshinImpact: return "\(rootFolder)GI/\(rawValue).json"
            case .starRail: return "\(rootFolder)HSR/\(rawValue).json"
            case .zenlessZone: return "\(rootFolder)ZZZ/\(rawValue).json" // 临时设定。
            }
        }

        // Bundle JSON Accessor.
        public var bundledJSONData: Data? {
            EnkaDBFileProvider.getBundledJSONFileData(fileNameStem: rawValue)
        }

        public func getBundledJSONObject<T: Decodable>(
            as: T.Type, decoderConfigurator: ((JSONDecoder) -> Void)? = nil
        )
            -> T? {
            EnkaDBFileProvider.getBundledJSONFileObject(
                fileNameStem: rawValue,
                type: T.self,
                decoderConfigurator: decoderConfigurator
            )
        }

        // MARK: Internal

        // Bundle JSON Accessor.
        static let bundledExtraLangTable: Enka.RawLocTables = {
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
        static let bundledRealNameTable: Enka.RawLocTables = {
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

        static var cases4GI: [Self] {
            Self.allCases.filter { $0.game == .genshinImpact }
        }

        static var cases4HSR: [Self] {
            Self.allCases.filter { $0.game == .starRail }
        }
    }
}
