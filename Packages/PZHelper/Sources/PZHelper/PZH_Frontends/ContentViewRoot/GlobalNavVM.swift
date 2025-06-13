// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GlobalNavVM

@Observable @MainActor
final class GlobalNavVM: Sendable, ObservableObject {
    static let shared = GlobalNavVM()

    var rootTabNav: ContentView.TabNav = {
        let initSelection: Int = {
            guard Defaults[.restoreTabOnLaunching] else { return 1 }
            let allBaseID = ContentView.TabNav.allCases.map(\.id)
            guard allBaseID.contains(Defaults[.appTabIndex]) else { return 1 }
            return Defaults[.appTabIndex]
        }()
        return .init(rootID: initSelection) ?? .today
    }() {
        willSet {
            guard rootTabNav != newValue else { return }
            Defaults[.appTabIndex] = newValue.rootID
            UserDefaults.baseSuite.synchronize()
            Broadcaster.shared.stopRootTabTasks()
            if newValue == .today {
                Broadcaster.shared.todayTabDidSwitchTo()
            }
        }
    }
}
