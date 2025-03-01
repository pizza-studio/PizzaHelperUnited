// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZHelper_Watch
import SwiftUI

@main
struct PizzaWatchApp: App {
    // MARK: Internal

    var body: some Scene {
        PZHelperWatch.makeMainScene(modelContainer: profileContainer)
    }

    // MARK: Private

    @State private var profileContainer = PZHelperWatch.getSharedModelContainer()
}
