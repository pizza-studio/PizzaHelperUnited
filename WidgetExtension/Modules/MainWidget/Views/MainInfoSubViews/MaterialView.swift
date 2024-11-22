// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GITodayMaterialsKit
import SwiftUI

@available(watchOS, unavailable)
struct MaterialView: View {
    // MARK: Lifecycle

    init(alternativeLayout: Bool = false, today: MaterialWeekday? = nil) {
        self.alternativeLayout = alternativeLayout
        self.today = today ?? .today()
    }

    // MARK: Internal

    let alternativeLayout: Bool
    var today: MaterialWeekday? = .today()

    var body: some View {
        GITodayMaterialsView4Widgets(
            alternativeLayout: alternativeLayout,
            today: today
        ) {
            Text("pzWidgetsKit.material.sunday", bundle: .main)
                .foregroundColor(Color("textColor3", bundle: .main))
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .legibilityShadow()
        }
    }
}
