// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import PZAccountKit
import SwiftUI

// MARK: - AbyssValueCell

struct AbyssValueCell: Identifiable, Hashable {
    // MARK: Lifecycle

    public init(value: String, description: String, avatarID: Int? = nil) {
        self.avatarID = avatarID
        self.value = value
        self.description = description.i18nHYLKit
    }

    public init(value: Int?, description: String, avatarID: Int? = nil) {
        self.avatarID = avatarID
        self.value = (value ?? -1).description
        self.description = description.i18nHYLKit
    }

    // MARK: Internal

    let id: Int = UUID().hashValue
    let avatarID: Int?
    var value: String
    var description: String

    @MainActor @ViewBuilder
    func makeAvatar() -> some View {
        switch avatarID {
        case .none: EmptyView()
        case let .some(avatarID):
            CharacterIconView(
                charID: avatarID.description,
                size: 48,
                circleClipped: true,
                clipToHead: true
            ).frame(width: 52, alignment: .center)
        }
    }
}

extension HoYo.AbyssReport4GI {
    func summarizedIntoCells(compact: Bool = false) -> [AbyssValueCell] {
        var result = [AbyssValueCell]()
        result.append(AbyssValueCell(value: maxFloor, description: "hylKit.abyssReport.gi.stat.deepest"))
        if compact {
            let appendCell = AbyssValueCell(value: totalBattleTimes, description: "hylKit.abyssReport.gi.stat.battle")
            var newCell = AbyssValueCell(value: totalWinTimes, description: "hylKit.abyssReport.gi.stat.win")
            newCell.value += " / \(appendCell.value)"
            newCell.description += " / \(appendCell.description)"
            result.append(newCell)
        } else {
            result.append(AbyssValueCell(value: totalBattleTimes, description: "hylKit.abyssReport.gi.stat.battle"))
            result.append(AbyssValueCell(value: totalWinTimes, description: "hylKit.abyssReport.gi.stat.win"))
        }
        result.append(AbyssValueCell(value: totalStar, description: "hylKit.abyssReport.gi.stat.star"))
        result.append(
            AbyssValueCell(
                value: takeDamageRank.first?.value,
                description: "hylKit.abyssReport.gi.stat.mostDamageTaken",
                avatarID: takeDamageRank.first?.avatarID
            )
        )
        result.append(
            AbyssValueCell(
                value: damageRank.first?.value,
                description: "hylKit.abyssReport.gi.stat.strongest",
                avatarID: damageRank.first?.avatarID
            )
        )
        result.append(
            AbyssValueCell(
                value: defeatRank.first?.value,
                description: "hylKit.abyssReport.gi.stat.mostDefeats",
                avatarID: defeatRank.first?.avatarID
            )
        )
        result.append(
            AbyssValueCell(
                value: normalSkillRank.first?.value,
                description: "hylKit.abyssReport.gi.stat.mostESkills",
                avatarID: normalSkillRank.first?.avatarID
            )
        )
        result.append(
            AbyssValueCell(
                value: energySkillRank.first?.value,
                description: "hylKit.abyssReport.gi.stat.mostQSkills",
                avatarID: energySkillRank.first?.avatarID
            )
        )
        return result
    }
}
