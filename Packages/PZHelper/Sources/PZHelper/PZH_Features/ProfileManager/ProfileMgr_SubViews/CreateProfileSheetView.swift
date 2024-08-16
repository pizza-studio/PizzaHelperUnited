// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

struct CreateProfileSheetView: View {
    // MARK: Lifecycle

    init(profile: PZProfileMO, isShown: Binding<Bool>) {
        self._isShown = isShown
        self.profile = profile
    }

    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                Text(verbatim: "# Under Construction")
            }
            .navigationTitle("profileMgr.new".i18nPZHelper)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel".i18nBaseKit) {
                        modelContext.rollback()
                        isShown.toggle()
                    }
                }
            }
        }
    }

    // MARK: Private

    @Binding private var isShown: Bool
    @State private var profile: PZProfileMO
    @Environment(\.modelContext) private var modelContext
}
