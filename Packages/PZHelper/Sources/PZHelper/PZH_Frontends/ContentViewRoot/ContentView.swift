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

    public init() {
        self._rootTabNavBinding = GlobalNavVM.shared.rootTabNavBindingNullable
    }

    // MARK: Public

    public var body: some View {
        NavigationSplitView(
            columnVisibility: $screenVM.splitViewVisibility,
            preferredCompactColumn: $viewColumn
        ) {
            NavigationStack {
                TodayTabPage(wrappedByNavStack: false)
                    .scrollContentBackground(.hidden)
                    .listRowMaterialBackground()
                    .listContainerBackground(thickMaterial: true)
                    .navBarTitleDisplayMode(.large)
            }
            .tint(Color.accessibilityAccent(colorScheme))
            #if os(macOS) && !targetEnvironment(macCatalyst)
                .frame(width: sideBarWidth)
            #endif
                .toolbar(removing: .sidebarToggle) // Remove toggle button
            #if !os(macOS)
                .toolbar(.hidden, for: .navigationBar) // Additional safeguard
            #endif
        } detail: {
            AppRootPageViewWrapper(tab: tabNavVM.rootTabNav)
                .appTabBarVisibility(.visible)
                .navigationBarBackButtonHidden(true)
                .tint(tintForCurrentTab)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(tintForCurrentTab)
        .apply { currentContent in
            hookSidebarAndPageHandlers(currentContent)
                .onChange(of: tabNavVM.rootTabNav) {
                    simpleTaptic(type: .selection)
                }
        }
        .navigationSplitViewColumnWidth(sideBarWidth)
        .environment(GachaVM.shared)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var screenVM = ScreenVM.shared
    @State private var viewColumn: NavigationSplitViewColumn = .content
    @Binding private var rootTabNavBinding: AppTabNav?

    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

    private var sideBarWidth: CGFloat { 375 }

    private var effectiveAppNavCases: [AppTabNav] {
        screenVM.isSidebarVisible ? AppTabNav.enabledSubCases : AppTabNav.allCases
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var tintForCurrentTab: Color {
        switch AppTabNav(rootID: tabNavVM.rootTabNav.rootID) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }

    @ViewBuilder
    private func hookSidebarAndPageHandlers(_ givenView: some View) -> some View {
        givenView
            // .task { fixMainColumnPageIfNeeded() }
            .onChange(of: screenVM.hashForTracking, initial: true) {
                fixMainColumnPageIfNeeded()
            }
    }

    private func fixMainColumnPageIfNeeded() {
        if screenVM.isSidebarVisible, tabNavVM.rootTabNav == .today {
            rootTabNavBinding = .showcaseDetail
        }
    }
}
