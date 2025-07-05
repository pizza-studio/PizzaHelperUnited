// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - ArtifactRating.RatingRequest

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension ArtifactRating {
    public struct RatingRequest {
        public var game: Enka.GameType
        public var charID: String
        public var characterElement: Enka.GameElement
        public var headOrFlower: Artifact
        public var handOrPlume: Artifact
        public var bodyOrSands: Artifact
        public var footOrGoblet: Artifact
        public var objectOrCirclet: Artifact
        public var neckHSR: Artifact?

        public var allArtifacts: [Artifact] {
            [headOrFlower, handOrPlume, bodyOrSands, footOrGoblet, objectOrCirclet, neckHSR].compactMap { $0 }
        }

        public var allValidArtifacts: [Artifact] {
            allArtifacts.filter(\.isValid)
        }
    }
}

// MARK: - ArtifactRating.RatingRequest.Artifact

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension ArtifactRating.RatingRequest {
    // MARK: Public

    public struct Artifact {
        public var mainProp: ArtifactRating.Appraiser.Param?
        public var type: Enka.ArtifactType
        public var star: Int = 5
        public var level: Int = 20
        public var setID: Int = -114_514
        public var subPanel: SubPropData = .init()
        public var effectiveRatio: Double = 1

        public var isNull: Bool {
            setID == -114_514
        }

        public var isValid: Bool {
            !isNull
        }
    }
}

// MARK: - ArtifactRating.RatingRequest.SubPropData

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension ArtifactRating.RatingRequest {
    public struct SubPropData: AbleToCodeSendHash {
        var hpDelta: Double = 0
        var attackDelta: Double = 0
        var defenceDelta: Double = 0
        var hpAddedRatio: Double = 0
        var attackAddedRatio: Double = 0
        var defenceAddedRatio: Double = 0
        var speedDelta: Double = 0
        var criticalChanceBase: Double = 0
        var criticalDamageBase: Double = 0
        var statusProbabilityBase: Double = 0
        var statusResistanceBase: Double = 0
        var breakDamageAddedRatioBase: Double = 0
        var elementalMastery: Double = 0
    }
}
