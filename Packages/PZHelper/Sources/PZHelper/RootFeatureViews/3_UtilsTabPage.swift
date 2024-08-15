// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@MainActor
struct UtilsTabPage: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verbatim: "传统意义上的工具页面。")
                    }
                    .multilineTextAlignment(.leading)
                    .font(.caption)
                } header: {
                    Text(verbatim: "该页面待施工")
                }
            }.formStyle(.grouped)
                .navigationTitle("tab.utils.fullTitle".i18nPZHelper)
                .listStyle(.insetGrouped)
        }
    }
}
