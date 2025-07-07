// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit

// MARK: - ArtifactRating

// swiftlint:disable cyclomatic_complexity

@available(iOS 17.0, macCatalyst 17.0, *)
public enum ArtifactRating {}

@available(iOS 17.0, macCatalyst 17.0, *)
public typealias ArtifactSubStatScore = ArtifactRating.SubStatScoreLevel

// MARK: - ArtifactRating.SubStatScoreLevel

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    public enum SubStatScoreLevel: Double, AbleToCodeSendHash {
        case highest = 100
        case higherPlus = 90
        case higher = 80
        case highPlus = 70
        case high = 60
        case medium = 50
        case low = 40
        case lower = 30
        case lowerLower = 20
        case lowest = 10
        case none = 0

        // MARK: Lifecycle

        /// Ref: https://github.com/Mar-7th/StarRailScore
        public init(march7thWeight: Double) {
            switch march7thWeight {
            case 1: self = .highest
            case 0.9 ..< 1: self = .higherPlus
            case 0.8 ..< 0.9: self = .higher
            case 0.7 ..< 0.8: self = .highPlus
            case 0.6 ..< 0.7: self = .high
            case 0.5 ..< 0.6: self = .medium
            case 0.4 ..< 0.5: self = .low
            case 0.3 ..< 0.4: self = .lower
            case 0.2 ..< 0.3: self = .lowerLower
            case 0.1 ..< 0.2: self = .lowest
            default: self = .none
            }
        }

        // MARK: Public

        public mutating func beStepsLower(_ steps: Int) {
            guard steps >= 1 else { return }
            for _ in 0 ..< steps {
                beOneStepLower()
            }
        }

        public mutating func beOneStepLower() {
            self = switch self {
            case .highest: .higherPlus
            case .higherPlus: .higher
            case .higher: .highPlus
            case .highPlus: .high
            case .high: .medium
            case .medium: .low
            case .low: .lower
            case .lower: .lowerLower
            case .lowerLower: .lowest
            case .lowest: .none
            case .none: .none
            }
        }
    }
}

// MARK: - ArtifactRating.Appraiser

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    public struct Appraiser {
        // MARK: Lifecycle

        public init(
            request: ArtifactRating.RatingRequest,
            rules: ArtifactRating.Rules? = nil
        ) {
            self.request = request
            self.rules = rules ?? Defaults[.artifactRatingRules]
        }

        // MARK: Public

        // 用于圣遗物评分统计的一个专属 Enum，仅包含会被圣遗物用到的词条。
        public enum Param: Hashable {
            case hpDelta
            case atkDelta
            case defDelta
            case hpAmp
            case atkAmp
            case defAmp
            case spdDelta
            case critChance
            case critDamage
            case statProb
            case statResis
            case breakDmg
            case healAmp
            case energyRecovery
            case elementalMastery
            case dmgAmp(Enka.GameElement?)
        }

        public let request: ArtifactRating.RatingRequest
        public let rules: ArtifactRating.Rules
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.Appraiser {
    public static func tellTier(score: Int) -> String {
        // 虽然原神每个角色只能装备五件圣遗物，
        // 但圣遗物最高等级是20级（星穹铁道的上限是15级），
        // 所以无须对两者的段位评级分开制定标准。
        switch score {
        case 1350...: "SSS+"
        case 1300 ..< 1350: "SSS"
        case 1250 ..< 1300: "SSS-"
        case 1200 ..< 1250: "SS+"
        case 1150 ..< 1200: "SS"
        case 1100 ..< 1150: "SS-"
        case 1050 ..< 1100: "S+"
        case 1000 ..< 1050: "S"
        case 950 ..< 1000: "S-"
        case 900 ..< 950: "A+"
        case 850 ..< 900: "A"
        case 800 ..< 850: "A-"
        case 750 ..< 800: "B+"
        case 700 ..< 750: "B"
        case 650 ..< 700: "B-"
        case 600 ..< 650: "C+"
        case 550 ..< 600: "C"
        case 500 ..< 550: "C-"
        case 450 ..< 500: "D+"
        case 400 ..< 450: "D"
        case 350 ..< 400: "D-"
        case 300 ..< 350: "E+"
        case 250 ..< 300: "E"
        case 200 ..< 250: "E-"
        default: "F"
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.RatingRequest.Artifact {
    /// Adjust dictionary contents for potential Hyperbloom Electro Roles.
    ///
    /// Theoreotically, any electro character can be turned into
    ///  a Hyperbloom trigger if any of the following 4-set is equipped.
    /// This affects the standards for benchmarking the artifacts.
    /// For example, if Raiden Shogun has a 4-set Paradise Lost equipped,
    ///  then her Element Master should be considered the most useful.
    @discardableResult
    func mutatingModelForSpecialRules(
        _ ratingModel: inout ArtifactRating.CharacterStatScoreModel,
        for request: ArtifactRating.RatingRequest,
        rules: ArtifactRating.Rules
    )
        -> ArtifactRating.Rules {
        var returnedValue = ArtifactRating.Rules()
        checkHyperBloomElectro: if rules.contains(.considerHyperbloomElectroRoles) {
            let hyperbloomSets4: Set<Int> = [15028, 15026, 15025, 10007]
            var sumDict: [Int: Int] = [:]
            guard let avatar = Enka.Sputnik.shared.db4GI.characters[request.charID]
            else { break checkHyperBloomElectro }
            let element = Enka.GameElement(rawValue: avatar.element) ?? request.characterElement
            guard element == .electro else { break checkHyperBloomElectro }
            request.allValidArtifacts.forEach { artifact in
                sumDict[artifact.setID, default: 0] += hyperbloomSets4.contains(artifact.setID) ? 1 : 0
            }
            let valuesTrimmed: [Int] = sumDict.values.compactMap { [2, 4].contains($0) ? $0 : nil }
            let patternsMatched: Bool = valuesTrimmed == [2, 2] || valuesTrimmed == [4]
            // 这样一判断的话，肯定不是四件套就是 2+2。
            let shouldBoost = sumDict.values.reduce(0, +) >= 4 && sumDict.keys.count <= 2 && patternsMatched
            guard shouldBoost else { break checkHyperBloomElectro }
            for key in ratingModel.keys {
                switch key {
                case .elementalMastery: ratingModel[.elementalMastery] = .highest
                default: break // ratingModel[key]?.beStepsLower(1)
                }
            }
            returnedValue.insert(.considerHyperbloomElectroRoles)
        }
        return returnedValue
    }

    @MainActor
    func getSubScore(
        for request: ArtifactRating.RatingRequest,
        rules: ArtifactRating.Rules
    )
        -> Double {
        var rulesAppliedToModel: ArtifactRating.Rules = []
        var ratingModel = ArtifactRating.CharacterStatScoreModel.getScoreModel(
            charID: request.charID
        ) { theModel in
            rulesAppliedToModel = mutatingModelForSpecialRules(&theModel, for: request, rules: rules)
        }
        let charMax = ArtifactRating.CharacterStatScoreModel.getMax(charID: request.charID)
        // 此处的圣遗物评分是按照每个词条获得增幅的次数来计算的，
        // 所以不需要针对不同的词条制定不同的 default roll。
        func getPt(_ base: Double, _ param: ArtifactRating.Appraiser.Param) -> Double {
            // Default Roll 是 1。为了与 SRS 算法一致，这里不再按照圣遗物星级对低星圣遗物做额外加偿处理。
            // 但唯一例外是元素精通。
            var defaultRoll = 1.0
            // 针对雷系超绽放圣遗物套装持有者，对元素精通启用特殊的 defaultRoll。
            gameCheck: switch request.game {
            case .genshinImpact where rulesAppliedToModel.contains(.considerHyperbloomElectroRoles):
                if param == .elementalMastery, request.characterElement == .electro {
                    defaultRoll = 0.7
                }
            default: break gameCheck
            }
            return (base / defaultRoll) * (ratingModel[param] ?? .none).rawValue
        }

        // 副词条处理。
        var stackedScore: [Double] = [
            getPt(subPanel.hpDelta, .hpDelta),
            getPt(subPanel.attackDelta, .atkDelta),
            getPt(subPanel.defenceDelta, .defDelta),
            getPt(subPanel.hpAddedRatio, .hpAmp),
            getPt(subPanel.attackAddedRatio, .atkAmp),
            getPt(subPanel.defenceAddedRatio, .defAmp),
            getPt(subPanel.speedDelta, .spdDelta),
            getPt(subPanel.criticalChanceBase, .critChance),
            getPt(subPanel.criticalDamageBase, .critDamage),
            getPt(subPanel.statusProbabilityBase, .statProb),
            getPt(subPanel.statusResistanceBase, .statResis),
            getPt(subPanel.elementalMastery, .elementalMastery),
        ]

        // 主词条处理。
        checkMainProps: do {
            guard let mainPropParam = mainProp else { break checkMainProps }
            // 按部位更新评分模型。
            ratingModel = ArtifactRating.CharacterStatScoreModel.getScoreModel(
                charID: request.charID,
                artifactType: type
            ) { theModel in
                mutatingModelForSpecialRules(&theModel, for: request, rules: rules)
            }
            typeAdd: switch type {
            case .giFlower, .hsrHead: ratingModel[.hpDelta] = .highest
            case .giPlume, .hsrHand: ratingModel[.atkDelta] = .highest
            default: break typeAdd
            }
            let mainPropWeightBase = Double(level + 1) / 16

            switch (request.game, mainPropParam) {
            case let (.genshinImpact, .dmgAmp(gobletAmpedElement)):
                // 元素伤害加成需要额外处理。
                // 预设情况下会尊重与角色属性对应的元素伤害加成。
                // 但是优菈、雷泽、辛焱等物理角色被专门指定优先尊重物理伤害加成。
                // 然后再检查杯子的伤害加成元素种类是否与被尊重的伤害加成元素一致。
                // 【注意】不一致的话，则这个杯子的主词条将不再参与计分。
                var predefinedElement: Enka.GameElement?
                ratingModel.keys.forEach { currentParam in
                    switch currentParam {
                    case let .dmgAmp(predefinedValue): predefinedElement = predefinedValue
                    default: return
                    }
                }
                guard let avatar = Enka.Sputnik.shared.db4GI.characters[request.charID] else { break checkMainProps }
                let avatarElement = Enka.GameElement(rawValue: avatar.element)
                let fallbackElement = request.characterElement
                predefinedElement = predefinedElement ?? avatarElement ?? fallbackElement

                // 特殊处理：风系角色的扩散伤害。比如说如雷万叶要打雷伤，此时带雷伤杯。

                var handleSwirl = false
                if rules.contains(.considerSwirls), (avatarElement ?? fallbackElement) == .anemo {
                    handleSwirl = [.anemo, .pyro, .hydro, .electro, .cryo].contains(predefinedElement)
                }

                if gobletAmpedElement == predefinedElement || handleSwirl {
                    stackedScore.append(getPt(mainPropWeightBase, mainPropParam))
                }
            case (.starRail, .spdDelta) where setID == 124:
                // 星穹铁道：哀歌覆国的诗人如果出现速度主词条的话，记 0 分。
                return 0
            default:
                stackedScore.append(getPt(mainPropWeightBase, mainPropParam))
            }
        }

        var finalResult = (stackedScore.reduce(0, +) / charMax) * 3 * effectiveRatio

        /// 星穹铁道的分数畸高，得乘以 0.4。
        switch request.game {
        case .starRail: finalResult *= 0.4
        default: break
        }

        return finalResult
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.Appraiser {
    @MainActor
    public func evaluate() -> ArtifactRating.ScoreResult? {
        var result = ArtifactRating.ScoreResult(
            game: request.game,
            charID: request.charID
        )

        let totalScore: Int = request.allArtifacts.map { artifact in
            let score = Int(artifact.getSubScore(for: request, rules: rules))
            switch artifact.type {
            case .giFlower, .hsrHead: result.stat1pt = score
            case .giPlume, .hsrHand: result.stat2pt = score
            case .giSands, .hsrBody: result.stat3pt = score
            case .giGoblet, .hsrFoot: result.stat4pt = score
            case .giCirclet, .hsrObject: result.stat5pt = score
            case .hsrNeck: result.stat6pt = score
            }
            return score
        }.reduce(0, +)

        result.allpt = totalScore
        result.result = Self.tellTier(score: totalScore)

        return result
    }
}

// MARK: - ArtifactRating.ScoreResult

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    public struct ScoreResult: Codable, Equatable, Hashable, Sendable {
        public var game: Enka.GameType
        public var charID: String
        public var stat1pt: Int = 0
        public var stat2pt: Int = 0
        public var stat3pt: Int = 0
        public var stat4pt: Int = 0
        public var stat5pt: Int = 0
        public var stat6pt: Int = 0
        public var allpt: Int = 0
        public var result: String = "N/A"

        public var sumExpression: String {
            switch game {
            case .genshinImpact:
                "\(stat1pt)+\(stat2pt)+\(stat3pt)+\(stat4pt)+\(stat5pt) = "
            case .starRail:
                "\(stat1pt)+\(stat2pt)+\(stat3pt)+\(stat4pt)+\(stat5pt)+\(stat6pt) = "
            case .zenlessZone: "114514" // 临时设定。
            }
        }

        public var isValid: Bool {
            guard allpt == stat1pt + stat2pt + stat3pt + stat4pt + stat5pt + stat6pt
            else { return false }
            guard stat1pt >= 0 else { return false }
            guard stat2pt >= 0 else { return false }
            guard stat3pt >= 0 else { return false }
            guard stat4pt >= 0 else { return false }
            guard stat5pt >= 0 else { return false }
            guard stat6pt >= 0 else { return false }
            return true
        }

        public func convertToCollectionModel(
            uid: String
        )
            -> ArtifactRating.CollectionModel {
            ArtifactRating.CollectionModel(
                uid: uid,
                charID: charID,
                totalScore: allpt,
                stat1Score: stat1pt,
                stat2Score: stat2pt,
                stat3Score: stat3pt,
                stat4Score: stat4pt,
                stat5Score: stat5pt,
                stat6Score: stat6pt
            )
        }
    }
}

// MARK: - ArtifactRating.CollectionModel

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    public struct CollectionModel: Codable {
        public var uid: String
        public var charID: String
        public var totalScore: Int
        public var stat1Score: Int
        public var stat2Score: Int
        public var stat3Score: Int
        public var stat4Score: Int
        public var stat5Score: Int
        public var stat6Score: Int
    }
}

// swiftlint:enable cyclomatic_complexity
