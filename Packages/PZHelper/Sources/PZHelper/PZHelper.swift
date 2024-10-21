// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftData
import SwiftUI

// MARK: - PZHelper

public enum PZHelper {}

extension PZHelper {
    @MainActor @SceneBuilder
    public static func makeMainScene() -> some Scene {
        WindowGroup {
            ContentView()
                .environment(\.horizontalSizeClass, .compact)
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 600, minHeight: 800)
            #endif
                .onAppear {
                    if !isApplicationBooted {
                        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
                    }
                    isApplicationBooted = true
                }
        }
        .windowResizability(.contentMinSize)
        .modelContainer(PZProfileActor.shared.modelContainer)
    }

    @MainActor public private(set) static var isApplicationBooted = false
}
