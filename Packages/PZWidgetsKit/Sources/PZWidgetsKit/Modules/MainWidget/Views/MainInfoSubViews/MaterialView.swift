// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

struct MaterialView: View {
    var today: MaterialWeekday = .today()

    var talentMaterialProvider: TalentMaterialProvider { .init(weekday: today) }
    var weaponMaterialProvider: WeaponMaterialProvider { .init(weekday: today) }

    var body: some View {
        if today != .sunday {
            VStack {
                HStack(spacing: -5) {
                    ForEach(
                        weaponMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                    }
                }
                HStack(spacing: -5) {
                    ForEach(
                        talentMaterialProvider.todaysMaterials,
                        id: \.imageString
                    ) { material in
                        Image(material.imageString)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        } else {
            Text("widget.material.sunday".localized)
                .foregroundColor(Color("textColor3"))
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
        }
    }
}
