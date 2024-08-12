// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import ArtifactRatingDB

// MARK: - ArtifactRating

public enum ArtifactRating {
    public typealias ModelDB = [String: RatingModel]
    public struct RatingModel: Codable, Hashable {
        public var main: [String: [Enka.PropertyType: Double]] = [:]
        public var weight: [Enka.PropertyType: Double] = [:]
        public var max: Double = 10
    }
}

extension ArtifactRating.ModelDB {
    public static func makeBundledDB() -> Self {
        var result = Self()
        let giDB = Self(game: .genshinImpact)
        let hsrDB = Self(game: .starRail)
        result = giDB
        hsrDB.forEach { key, value in
            result[key] = value
        }
        return result
    }

    public init(game: Enka.GameType) {
        let fileNameStem: String = switch game {
        case .genshinImpact: "ARDB4GI"
        case .starRail: "ARDB4HSR"
        }
        self = ARDB.getBundledJSONFileObject(
            fileNameStem: fileNameStem, type: Self.self
        )!
    }
}
