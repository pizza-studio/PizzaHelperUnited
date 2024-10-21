// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI

struct ExpeditionsView: View {
    let expeditions: [any Expedition]
    var useAsyncImage: Bool = false

    var body: some View {
        VStack {
            ForEach(expeditions, id: \.iconURL) { expedition in
                EachExpeditionView(
                    expedition: expedition,
                    useAsyncImage: useAsyncImage
                )
            }
        }
//        .background(WidgetBackgroundView(background: .randomNamecardBackground, darkModeOn: true))
    }
}
