// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZHelper
import SwiftData
import SwiftUI

@main
@MainActor
struct ThePizzaHelperApp: App {
    // MARK: Internal

    var body: some Scene {
        PZHelper.makeMainScene(modelContainer: profileContainer)
    }

    // MARK: Private

    @State private var profileContainer = PZHelper.getSharedModelContainer()
}
