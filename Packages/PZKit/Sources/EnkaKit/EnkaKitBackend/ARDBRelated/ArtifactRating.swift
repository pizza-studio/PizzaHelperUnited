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

extension ArtifactRating {
    public static func initBundledCountDB() -> [String: Enka.PropertyType] {
        ARDB.getBundledJSONFileObject(
            fileNameStem: "CountDB4GI", type: [String: Enka.PropertyType].self
        )!
    }

    public static func calculateSteps(
        against appendPropIdList: [Int],
        using db: [String: Enka.PropertyType],
        dbExpiryHandler: (() -> Void)? = nil
    )
        -> [Enka.PropertyType: Int] {
        var result = [Enka.PropertyType: Int]() // [PropName: Steps]
        for propID in appendPropIdList {
            // Shouldn't happen unless the database is expired.
            guard let propName = db[propID.description] else {
                dbExpiryHandler?()
                return [:]
            }
            result[propName, default: 0] += 1
        }
        return result
    }
}
