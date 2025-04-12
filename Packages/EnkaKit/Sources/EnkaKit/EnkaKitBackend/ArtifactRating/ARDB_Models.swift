// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import ArtifactRatingDB
import PZBaseKit

// MARK: - ArtifactRating

extension ArtifactRating {
    public typealias ModelDB = [String: RatingModel]
    public struct RatingModel: AbleToCodeSendHash {
        public var main: [String: [Enka.PropertyType: Double]] = [:]
        public var weight: [Enka.PropertyType: Double] = [:]
        public var max: Double = 10
    }

    @MainActor public static var sharedDB: ArtifactRating.ModelDB {
        ArtifactRating.ARSputnik.shared.arDB
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
        let fileNameStem = switch game {
        case .genshinImpact: "ARDB4GI"
        case .starRail: "ARDB4HSR"
        case .zenlessZone: "ARDB4ZZZ" // 临时设定。
        }
        self = ARDB.getBundledJSONFileObject(
            fileNameStem: fileNameStem, type: Self.self
        )!
    }

    @MainActor
    public func isExpired<T: EKQueriedProfileProtocol>(against profile: T) -> Bool {
        let targetIDs: Set<String> = .init(profile.avatarDetailList.map(\.avatarId.description))
        guard targetIDs.isSubset(of: Set<String>(ArtifactRating.sharedDB.keys)) else { return true }
        let effectiveModels = compactMap { theKey, theModel in
            targetIDs.contains(theKey) ? theModel : nil
        }
        return effectiveModels.areAllContentsValid
    }
}

extension [ArtifactRating.RatingModel] {
    fileprivate var areAllContentsValid: Bool {
        let effectiveCount: Int = map { theModel in
            theModel.weight.map(\.value).reduce(0, +) > 0 ? 1 : 0
        }.reduce(0, +)
        return effectiveCount == count
    }
}

extension ArtifactRating {
    public static func initBundledCountDB() -> [String: Enka.PropertyType] {
        ARDB.getBundledJSONFileObject(
            fileNameStem: "CountDB4GI", type: [String: Enka.PropertyType].self
        )!
    }

    public static func calculateCounts(
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

// MARK: - ArtifactRating.CharacterStatScoreModel

extension ArtifactRating {
    public typealias CharacterStatScoreModel = [ArtifactRating.Appraiser.Param: ArtifactSubStatScore]
}

extension ArtifactRating.CharacterStatScoreModel {
    /// 查詢得分模型專用的函式。
    /// - Parameters:
    ///   - charID: 角色 ID
    ///   - artifactType: 聖遺物種類。指定了的話就查詢主詞條，如果沒指定（也就是 nil）那就查詢副詞條。
    /// - Returns: [ArtifactRating.Appraiser.Param: ArtifactSubStatScore]
    @MainActor
    static func getScoreModel(
        charID: String,
        artifactType: Enka.ArtifactType? = nil,
        mutationHandler: ((inout Self) -> Void)? = nil
    )
        -> Self {
        var result = Self()
        guard let queried = ArtifactRating.sharedDB[charID] else { return result }
        if let artifactType = artifactType,
           let foundMainStack = queried.main[artifactType.artifactRatingTypeIDStr] {
            foundMainStack.forEach { key, value in
                guard let paramType = key.appraisableArtifactParam else { return }
                result[paramType] = .init(march7thWeight: value)
            }
        } else {
            queried.weight.forEach { key, value in
                guard let paramType = key.appraisableArtifactParam else { return }
                result[paramType] = .init(march7thWeight: value)
            }
        }
        mutationHandler?(&result)
        return result
    }

    @MainActor
    static func getMax(charID: String) -> Double {
        ArtifactRating.sharedDB[charID]?.max ?? 10
    }
}
