// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import PZAccountKit
import PZBaseKit
import PZHelper
import SwiftData
import SwiftUI

@main
@MainActor
struct UnitedPizzaHelperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.horizontalSizeClass, .compact)
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 600, minHeight: 800)
            #endif
        }
        .windowResizability(.contentMinSize)
        .modelContainer(PZHelper.sharedContainer)
    }
}
