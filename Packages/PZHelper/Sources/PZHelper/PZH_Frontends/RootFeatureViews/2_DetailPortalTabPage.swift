// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import SwiftUI

@MainActor
struct DetailPortalTabPage: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                CaseQuerySection(theDB: sharedDB.db4GI)
                CaseQuerySection(theDB: sharedDB.db4HSR)
            }
            .formStyle(.grouped)
            .navigationTitle("tab.details.fullTitle".i18nPZHelper)
            .navigationDestination(for: Enka.QueriedProfileGI.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4GI
                )
            }
            .navigationDestination(for: Enka.QueriedProfileHSR.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4HSR
                )
            }
        }
    }

    // MARK: Private

    @State private var sharedDB = Enka.Sputnik.shared
}
