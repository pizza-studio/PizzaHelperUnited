// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI

@available(watchOS, unavailable)
struct WidgetErrorView: View {
    let error: any Error
    let message: String

    var body: some View {
        Text(error.localizedDescription)
            .font(.title3)
            .foregroundColor(.gray)
            .padding()
    }
}
