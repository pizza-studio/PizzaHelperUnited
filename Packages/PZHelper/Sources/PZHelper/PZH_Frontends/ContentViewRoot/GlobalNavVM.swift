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
    // MARK: Public

    @MainActor @ViewBuilder
    public func sharedToolbarNavPicker(allCases: Bool) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppTabNav.enabledSubCases : AppTabNav.allCases
        Picker("".description, selection: $this.rootTabNav.animation()) {
            ForEach(effectiveCases) { navCase in
                if navCase.isExposed {
                    HStack {
                        navCase.icon
                        navCase.labelNameText
                    }
                    .tag(navCase)
                }
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .fixedSize()
        .blurMaterialBackground(enabled: !OS.liquidGlassThemeSuspected)
        .clipShape(.capsule)
    }

    // MARK: Internal

    static let shared = GlobalNavVM()

    static let isAppKit = OS.type == .macOS && !OS.isCatalyst

    var appTabVM = AppTabBarVM.shared

    var rootTabNavBindingNullable: Binding<AppTabNav?> {
        .init(
            get: {
                self.rootTabNav
            },
            set: { newValue in
                self.rootTabNav = newValue ?? .today
            }
        )
    }

    var rootTabNav: AppTabNav = {
        let initSelection: Int = {
            guard Defaults[.restoreTabOnLaunching] else { return 1 }
            let allBaseID = AppTabNav.allCases.map(\.id)
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
