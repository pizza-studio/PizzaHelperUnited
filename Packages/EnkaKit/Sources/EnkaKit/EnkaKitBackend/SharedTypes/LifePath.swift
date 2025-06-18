// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Enka.LifePath

extension Enka {
    public enum LifePath: String, AbleToCodeSendHash, CaseIterable {
        case none = "None"
        case destruction = "Warrior"
        case hunt = "Rogue"
        case erudition = "Mage"
        case harmony = "Shaman"
        case nihility = "Warlock"
        case preservation = "Knight"
        case abundance = "Priest"
        case remembrance = "Memory"
    }
}

extension Enka.LifePath {
    public var iconFileName: String {
        String(describing: self).capitalized
    }

    public var iconAssetName: String {
        "path_\(String(describing: self).capitalized)"
    }

    public var publicName: String {
        String(describing: self).capitalized
    }
}

// MARK: - Enka.GenshinLifePathRecord

extension Enka {
    public struct GenshinLifePathRecord: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: CodingKeys.id)
            let maybeRawPath = try container.decode(String.self, forKey: CodingKeys.path)
            let matchedPath = Enka.LifePath.allCases.first { $0.publicName == maybeRawPath }
            if let matchedPath {
                self.path = matchedPath
            } else {
                self.path = try container.decode(Enka.LifePath.self, forKey: CodingKeys.path)
            }
        }

        // MARK: Public

        public let id: String
        public let path: Enka.LifePath

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: CodingKeys.id)
            try container.encode(path.publicName, forKey: CodingKeys.path)
        }

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case id
            case path
        }
    }
}

extension Enka.GenshinLifePathRecord {
    public static let allMap: [String: Enka.LifePath] = {
        guard let url = Bundle.module.url(
            forResource: "GenshinLifePathMap", withExtension: "json"
        ) else { return [:] }
        do {
            let data = try Data(contentsOf: url)
            let rawResult = try JSONDecoder().decode([Enka.GenshinLifePathRecord].self, from: data)
            var result: [String: Enka.LifePath] = [:]
            rawResult.forEach {
                result[$0.id] = $0.path
            }
            return result
        } catch {
            NSLog("EnkaKit: Cannot access RealNameDict.json.")
            return [:]
        }
    }()

    /// Only works with Genshin Character IDs.
    public static func guessPath(for charID: String) -> Enka.LifePath? {
        allMap["\(charID.prefix(12))"] ?? allMap["\(charID.prefix(8))"]
    }
}
