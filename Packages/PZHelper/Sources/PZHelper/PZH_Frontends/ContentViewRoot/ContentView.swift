// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import GachaKit
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $tabNavVM.rootTabNav) {
                ForEach(AppTabNav.allCases) { navCase in
                    if navCase.isExposed {
                        navCase
                        #if targetEnvironment(macCatalyst)
                        .toolbar(.hidden, for: .tabBar)
                        #endif
                    }
                }
            }
            .appTabBarVisibility(.visible)
            .tint(tintForCurrentTab)
            tabNavVM.tabBarForMacCatalyst
                .fixedSize(horizontal: false, vertical: true)
        }
        #if targetEnvironment(macCatalyst)
        .apply { theContent in
            Group {
                #if compiler(>=6.0) && canImport(UIKit, _version: 18.0)
                if #unavailable(iOS 18.0), #unavailable(macCatalyst 18.0) {
                    theContent
                } else {
                    theContent
                        .tabViewStyle(.sidebarAdaptable)
                        .tabViewCustomization(.none)
                }
                #else
                theContent
                #endif
            }
        }
        #endif
        .onChange(of: tabNavVM.rootTabNav.rootID) {
            simpleTaptic(type: .selection)
        }
        .environment(GachaVM.shared)
    }

    // MARK: Internal

    @Default(.appTabIndex) var appIndex: Int

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var appTabVM = AppTabBarVM.shared

    private var tintForCurrentTab: Color {
        switch AppTabNav(rootID: tabNavVM.rootTabNav.rootID) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }
}
