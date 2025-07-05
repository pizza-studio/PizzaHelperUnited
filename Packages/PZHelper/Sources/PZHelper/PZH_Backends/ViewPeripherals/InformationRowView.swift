// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: String, @ViewBuilder labelContent: @escaping () -> L) {
        self.title = title
        self.labelContent = labelContent
    }

    // MARK: Internal

    @ViewBuilder let labelContent: () -> L

    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            labelContent()
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipShape(Rectangle())
        }
    }
}
