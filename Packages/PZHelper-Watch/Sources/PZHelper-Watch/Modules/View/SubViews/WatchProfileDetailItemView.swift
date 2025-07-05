// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(watchOS 10.0, *)
struct WatchProfileDetailItemView: View {
    var title: LocalizedStringKey
    var value: String
    var icon: Image?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .frame(width: 15, height: 15)
                        .scaledToFit()
                }
                Text(title, bundle: .module)
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            Text(value)
        }
    }
}
