// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftData
import SwiftUI

// MARK: - PZHelperWatch

public enum PZHelperWatch {}

extension PZHelperWatch {
    @MainActor @SceneBuilder
    public static func makeMainScene() -> some Scene {
        WindowGroup {
            ContentView()
                .environment(\.horizontalSizeClass, .compact)
                .defaultAppStorage(.baseSuite)
                .onAppear {
                    if !isApplicationBooted {
                        startupTasks()
                    }
                    isApplicationBooted = true
                }
        }
        .modelContainer(PZProfileActor.shared.modelContainer)
    }

    @MainActor public private(set) static var isApplicationBooted = false
}

extension PZHelperWatch {
    @MainActor
    private static func startupTasks() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
    }
}
