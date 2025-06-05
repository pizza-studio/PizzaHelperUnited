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
            VStack(spacing: 0) {
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
            ZStack(alignment: .trailing) {
                HStack(spacing: containerSize.height * 0.3) {
                    ForEach(
                        supplier.weaponMaterials,
                        id: \.nameTag
                    ) { material in
                        material.iconObj
                            .resizable()
                            .scaledToFit()
                    }
                }
                .legibilityShadow(isText: false)
                .brightness(-0.2)
                .padding([.bottom], containerSize.height * 0.2)
                .padding([.trailing], containerSize.height * 0.4)
                HStack(spacing: containerSize.height * 0.3) {
                    ForEach(
                        supplier.talentMaterials,
                        id: \.nameTag
                    ) { material in
                        material.iconObj
                            .resizable()
                            .scaledToFit()
                    }
                }
                .legibilityShadow()
                .padding([.top], containerSize.height * 0.2)
                .padding([.leading], containerSize.height * 0.4)
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        containerSize = proxy.size
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var containerSize: CGSize = .init(width: 250, height: 40)

    private let alternativeLayout: Bool
    private let today: GITodayMaterial.AvailableWeekDay?
    private let promptOnSunday: () -> T
    private let supplier: GITodayMaterial.Supplier
}

//
// #Preview {
//  HStack {
//    Spacer()
//    GITodayMaterialsView4Widgets(alternativeLayout: true, today: .TueFri)
//      .frame(height: 35)
//    Spacer()
//  }.frame(width: 420, height: 200)
// }
