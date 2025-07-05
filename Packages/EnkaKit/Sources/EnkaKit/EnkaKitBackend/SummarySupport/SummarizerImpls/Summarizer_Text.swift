// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension Enka.AvatarSummarized {
    public var asText: String { makeTextSummary(useMarkDown: false) }
    public var asMarkDown: String { makeTextSummary(useMarkDown: true) }

    private func makeTextSummary(useMarkDown: Bool = false) -> String {
        var resultLines = useMarkDown ? [] : ["//====================="]

        func addSeparator(finalLine: Bool = false) {
            if !useMarkDown {
                resultLines.append(finalLine ? "//=====================" : "//---------------------")
            }
        }

        func indentNode(_ level: UInt = 0) -> String {
            if !useMarkDown {
                " \(String(repeating: " ", count: Int(level)))→ "
            } else {
                "- ###\(String(repeating: "#", count: Int(level))) "
            }
        }

        func indent(_ level: UInt = 0) -> String {
            if !useMarkDown {
                " \(String(repeating: " ", count: Int(level)))"
            } else {
                "\(String(repeating: "\t", count: Int(level)))- "
            }
        }

        func emph(_ str: String) -> String {
            useMarkDown ? "**\(str)**" : str
        }

        // 姓名, 等级, 命之座, 天赋等级
        var headLine = useMarkDown ? "### " : " "
        headLine.append(mainInfo.name + " ")
        let terms = mainInfo.terms
        let eidolonInitial = switch game {
        case .genshinImpact: "C"
        case .starRail: "E"
        case .zenlessZone: "M" // Mindscape Cinema. // 临时设定。
        }
        headLine
            .append("[\(terms.levelNameShortened)\(mainInfo.avatarLevel), \(eidolonInitial)\(mainInfo.constellation)]")
        var skills = mainInfo.baseSkills.toArray
        if game == .genshinImpact {
            skills = skills.dropLast(1)
        }
        let skillLevels: String = skills.map { skillUnit in
            if let addedLevel = skillUnit.levelAddition {
                let strDeltaDisplay = "(+\(addedLevel))"
                return skillUnit.baseLevel.description + strDeltaDisplay
            } else {
                return skillUnit.baseLevel.description
            }
        }.joined(separator: ", ")
        headLine.append(" [\(skillLevels)]")
        resultLines.append(headLine)
        addSeparator()

        if let equippedWeapon = equippedWeapon {
            let weaponTextCells: [String] = [
                equippedWeapon.localizedName,
                "(lv\(equippedWeapon.trainedLevel), ★\(equippedWeapon.rarityStars), ❖\(equippedWeapon.refinement))",
            ]
            resultLines.append("\(indent(0))\(emph(weaponTextCells.joined(separator: " ")))")
            equippedWeapon.allProps.forEach { currentProp in
                var weaponProps = "\(indent(1))"
                let weaponPropName = currentProp.localizedTitle
                weaponProps.append("[\(weaponPropName): \(currentProp.valueString)]")
                resultLines.append(weaponProps)
            }
            addSeparator()
        }

        (avatarPropertiesA + avatarPropertiesB).forEach { currentProperty in
            resultLines.append("\(indent(0))[\(currentProperty.localizedTitle): \(currentProperty.valueString)]")
        }
        addSeparator()

        artifacts.enumerated().forEach { _, currentArtifact in
            var currentArtifactPropName = currentArtifact.mainProp.localizedTitle
            let mainPropStr = "\(currentArtifactPropName): \(currentArtifact.mainProp.valueString)"
            let emojiRep = currentArtifact.type.emojiRepresentable
            let suiteName = currentArtifact.setNameLocalized
            let rankLevelATF = currentArtifact.rarityStars
            let lvATF = currentArtifact.trainedLevel
            resultLines
                .append("\(indent(0))\(emojiRep) \(emph(mainPropStr)) (★\(rankLevelATF) lv.\(lvATF) \(suiteName))")
            var arrSubProps: [String] = []
            currentArtifact.subProps.forEach { currentAttr in
                currentArtifactPropName = currentAttr.localizedTitle
                arrSubProps.append("[\(currentArtifactPropName): \(currentAttr.valueString)]")
            }
            resultLines.append("\(indent(1))\(arrSubProps.joined(separator: " "))")
        }

        addSeparator(finalLine: true)
        return resultLines.joined(separator: "\n")
    }
}
