// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - PZHelperWatch

public enum PZHelperWatch {}

extension PZHelperWatch {
    @MainActor
    public struct WatchApp: App {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var body: some Scene {
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
                    .onAppBecomeActive {
                        Task { @MainActor in
                            await ProfileManagerVM.shared
                                .profileActor?
                                .syncAllDataToUserDefaults()
                        }
                        Task {
                            await ASMetaSputnik.shared.updateMeta()
                        }
                    }
            }
        }
    }

    @MainActor public private(set) static var isApplicationBooted = false
}

extension PZHelperWatch {
    @MainActor
    private static func startupTasks() {
        Task { @MainActor in
            await ProfileManagerVM.shared
                .profileActor?
                .tryAutoInheritOldLocalAccounts(resetNotifications: true)
        }
    }
}
