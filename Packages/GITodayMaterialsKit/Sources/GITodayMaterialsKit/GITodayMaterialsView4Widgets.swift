// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(watchOS, unavailable)
public struct GITodayMaterialsView4Widgets<T: View>: View {
    // MARK: Lifecycle

    public init(
        alternativeLayout: Bool,
        today: GITodayMaterial.AvailableWeekDay?,
        promptOnSunday: (@escaping () -> T) = EmptyView.init
    ) {
        self.alternativeLayout = alternativeLayout
        self.today = today
        self.promptOnSunday = promptOnSunday
        self.supplier = .init(weekday: today)
    }

    // MARK: Public

    public var body: some View {
        if today == nil {
            promptOnSunday()
        } else if !alternativeLayout {
            VStack {
                HStack(spacing: -5) {
                    ForEach(
                        supplier.weaponMaterials,
                        id: \.nameTag
                    ) { material in
                        material.iconObj
                            .resizable()
                            .scaledToFit()
                    }
                }
                HStack(spacing: -5) {
                    ForEach(
                        supplier.talentMaterials,
                        id: \.nameTag
                    ) { material in
                        material.iconObj
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .legibilityShadow(isText: false)
        } else {
            GeometryReader { g in
                ZStack {
                    HStack(spacing: g.size.height * 0.3) {
                        ForEach(
                            supplier.weaponMaterials,
                            id: \.nameTag
                        ) { material in
                            material.iconObj
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding([.trailing, .bottom], g.size.height * 0.2)
                    HStack(spacing: g.size.height * 0.3) {
                        ForEach(
                            supplier.talentMaterials,
                            id: \.nameTag
                        ) { material in
                            material.iconObj
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding([.top], g.size.height * 0.2)
                    .padding([.leading], g.size.height * 0.7)
                }
                .legibilityShadow(isText: false)
            }
        }
    }

    // MARK: Private

    private let alternativeLayout: Bool
    private let today: GITodayMaterial.AvailableWeekDay?
    private let promptOnSunday: () -> T
    private let supplier: GITodayMaterial.Supplier
}
