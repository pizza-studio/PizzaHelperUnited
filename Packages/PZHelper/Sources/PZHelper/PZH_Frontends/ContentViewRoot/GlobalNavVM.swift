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

    @ViewBuilder public var tabBarForMacCatalyst: some View {
        if OS.type == .macOS, appTabVM.latestVisibility != .hidden {
            HStack {
                ForEach(AppTabNav.allCases) { navCase in
                    let isChosen: Bool = navCase == self.rootTabNav
                    if navCase.isExposed {
                        Button {
                            withAnimation(.easeInOut) {
                                self.rootTabNav = navCase
                            }
                        } label: {
                            navCase.label
                                .fixedSize()
                                .labelStyle(.titleAndIcon)
                                .fontWidth(.compressed)
                                .fontWeight(isChosen ? .bold : .regular)
                                .foregroundStyle(isChosen ? Color.accentColor : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .id(navCase)
                    }
                }
            }
            .blurMaterialBackground()
            .frame(height: 50)
        }
    }

    // MARK: Internal

    static let shared = GlobalNavVM()

    var appTabVM = AppTabBarVM.shared

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
