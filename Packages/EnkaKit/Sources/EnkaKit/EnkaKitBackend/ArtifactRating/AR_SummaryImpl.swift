// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.AvatarSummarized {
    @MainActor
    public mutating func rateMyArtifacts() {
        guard let request = convert2ArtifactRatingModel() else { return }
        artifactRatingResult = ArtifactRating.Appraiser(request: request).evaluate()
        if let result = artifactRatingResult {
            updateArtifacts { oldArray in
                oldArray.map { currentArtifact in
                    var ratedArtifact = currentArtifact
                    switch ratedArtifact.type {
                    case .giFlower, .hsrHead: ratedArtifact.ratedScore = result.stat1pt
                    case .giPlume, .hsrHand: ratedArtifact.ratedScore = result.stat2pt
                    case .giSands, .hsrBody: ratedArtifact.ratedScore = result.stat3pt
                    case .giGoblet, .hsrFoot: ratedArtifact.ratedScore = result.stat4pt
                    case .giCirclet, .hsrObject: ratedArtifact.ratedScore = result.stat5pt
                    case .hsrNeck: ratedArtifact.ratedScore = result.stat6pt
                    }
                    return ratedArtifact
                }
            }
        }
    }

    @MainActor
    public func artifactsRated() -> Self {
        var this = self
        this.rateMyArtifacts()
        return this
    }

    public func convert2ArtifactRatingModel() -> ArtifactRating.RatingRequest? {
        let extractedData = extractArtifactSetData()
        switch game {
        case .genshinImpact:
            let charID: String = switch mainInfo.idExpressable.nameObj {
            case .protagonist:
                "\(mainInfo.uniqueCharId.prefix(8))_\(mainInfo.element.rawValueForHSR)"
            case let .someoneElse(pid: pid):
                pid.prefix(8).description
            }
            return ArtifactRating.RatingRequest(
                game: .genshinImpact,
                charID: charID,
                characterElement: mainInfo.element,
                headOrFlower: extractedData[.giFlower] ?? .init(type: .giFlower),
                handOrPlume: extractedData[.giPlume] ?? .init(type: .giPlume),
                bodyOrSands: extractedData[.giSands] ?? .init(type: .giSands),
                footOrGoblet: extractedData[.giGoblet] ?? .init(type: .giGoblet),
                objectOrCirclet: extractedData[.giCirclet] ?? .init(type: .giCirclet)
            )
        case .starRail:
            return ArtifactRating.RatingRequest(
                game: .starRail,
                charID: mainInfo.uniqueCharId,
                characterElement: mainInfo.element,
                headOrFlower: extractedData[.hsrHead] ?? .init(type: .hsrHead),
                handOrPlume: extractedData[.hsrHand] ?? .init(type: .hsrHand),
                bodyOrSands: extractedData[.hsrBody] ?? .init(type: .hsrBody),
                footOrGoblet: extractedData[.hsrFoot] ?? .init(type: .hsrFoot),
                objectOrCirclet: extractedData[.hsrObject] ?? .init(type: .hsrObject),
                neckHSR: extractedData[.hsrNeck] ?? .init(type: .hsrNeck)
            )
        case .zenlessZone: return nil // 临时设定。
        }
    }

    private typealias ArtifactsDataDictionary =
        [Enka.ArtifactType: ArtifactRating.RatingRequest.Artifact]

    // swiftlint:disable cyclomatic_complexity
    private func extractArtifactSetData() -> ArtifactsDataDictionary {
        var arrResult = ArtifactsDataDictionary()
        artifacts.forEach { thisSummarizedArtifact in
            var result = ArtifactRating.RatingRequest.Artifact(
                type: thisSummarizedArtifact.type
            )
            let artifactType = thisSummarizedArtifact.type
            result.star = thisSummarizedArtifact.rarityStars
            result.setID = thisSummarizedArtifact.setID
            result.level = thisSummarizedArtifact.trainedLevel
            // 副词条
            thisSummarizedArtifact.subProps.forEach { thisPropPair in
                guard let typeAppraisable = thisPropPair.type.appraisableArtifactParam else { return }
                let valueForRating = Double(thisPropPair.count) // + (Double(thisPropPair.step ?? 0) * 0.1)
                switch typeAppraisable {
                case .hpDelta: result.subPanel.hpDelta = valueForRating
                case .atkDelta: result.subPanel.attackDelta = valueForRating
                case .defDelta: result.subPanel.defenceDelta = valueForRating
                case .hpAmp: result.subPanel.hpAddedRatio = valueForRating
                case .atkAmp: result.subPanel.attackAddedRatio = valueForRating
                case .defAmp: result.subPanel.defenceAddedRatio = valueForRating
                case .spdDelta:
                    result.subPanel.speedDelta = valueForRating
                    // 星穹铁道：哀歌覆国的诗人如果出现速度词条且计数超过 1 的话，按照计数扣分。
                    gameCheck: switch thisSummarizedArtifact.game {
                    case .genshinImpact: break gameCheck
                    case .starRail where thisSummarizedArtifact.setID == 124:
                        switch typeAppraisable {
                        case .spdDelta where thisPropPair.count > 2:
                            result.effectiveRatio = 1.0 / Double(thisPropPair.count)
                        default: break gameCheck
                        }
                    default: break gameCheck
                    }
                case .critChance: result.subPanel.criticalChanceBase = valueForRating
                case .critDamage: result.subPanel.criticalDamageBase = valueForRating
                case .statProb: result.subPanel.statusProbabilityBase = valueForRating
                case .statResis: result.subPanel.statusResistanceBase = valueForRating
                case .breakDmg: result.subPanel.breakDamageAddedRatioBase = valueForRating
                case .elementalMastery: result.subPanel.elementalMastery = valueForRating
                case .healAmp: return // 主词条专属项目「治疗量加成」。
                case .energyRecovery: return // 主词条专属项目「元素充能效率」。
                case .dmgAmp: return // 主词条专属项目「元素伤害加成」。
                }
            }
            result.mainProp = thisSummarizedArtifact.mainProp.type.appraisableArtifactParam
            arrResult[artifactType] = result
        }
        return arrResult
    }
    // swiftlint:enable cyclomatic_complexity
}
