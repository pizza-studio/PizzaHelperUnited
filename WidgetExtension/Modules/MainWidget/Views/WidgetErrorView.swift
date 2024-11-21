// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(watchOS, unavailable)
struct WidgetErrorView: View {
    let error: any Error
    let message: String

    var body: some View {
        HStack(alignment: .top) {
            Button(intent: WidgetRefreshIntent()) {
                Image(systemSymbol: .arrowClockwiseCircle)
                    .font(.title3)
                    .foregroundColor(Color("textColor3", bundle: .main))
                    .clipShape(.circle)
                    .widgetLegibilityShadow()
            }
            .buttonStyle(.plain)
            .padding()
            Text(error.localizedDescription)
                .bold()
                .foregroundColor(.gray)
                .widgetLegibilityShadow()
        }
        .padding(20)
    }
}
