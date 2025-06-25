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
        self.rootTabNavBinding = GlobalNavVM.shared.rootTabNavBindingNullable
    }

    // MARK: Public

    public var body: some View {
        NavigationSplitView(
            columnVisibility: $broadcaster.splitViewVisibility,
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
            tabNavVM.rootTabNav.body
                .appTabBarVisibility(.visible)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: isCompact ? .bottomBar : .cancellationAction) {
                        if !isCompact {
                            tabNavVM.sharedToolbarNavPicker(
                                allCases: !isSidebarVisible,
                                isMenu: false
                            )
                        } else {
                            tabNavVM.bottomTabBarForCompactLayout(allCases: !isSidebarVisible)
                        }
                    }
                }
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

    // MARK: Internal

    let rootTabNavBinding: Binding<AppTabNav?>

    @Default(.appTabIndex) var appIndex: Int

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var orientation = DeviceOrientation()
    @State private var viewColumn: NavigationSplitViewColumn = .content

    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

    private var sideBarWidth: CGFloat { 375 }

    private var effectiveAppNavCases: [AppTabNav] {
        isSidebarVisible ? AppTabNav.enabledSubCases : AppTabNav.allCases
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var sideBarConditionMonitoringHash: Int {
        var hasher = Hasher()
        hasher.combine(horizontalSizeClass)
        hasher.combine(orientation.orientation)
        return hasher.finalize()
    }

    private var tintForCurrentTab: Color {
        switch AppTabNav(rootID: tabNavVM.rootTabNav.rootID) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }

    private var isSidebarVisible: Bool {
        Broadcaster.shared.splitViewVisibility == .all && horizontalSizeClass != .compact
    }

    @ViewBuilder
    private func hookSidebarAndPageHandlers(_ givenView: some View) -> some View {
        givenView
            .onChange(of: sideBarConditionMonitoringHash, initial: true) { _, newValue in
                updateSidebarHandlingStatus()
                if isSidebarVisible, tabNavVM.rootTabNav == .today {
                    rootTabNavBinding.wrappedValue = .showcaseDetail
                }
            }
            .onDisappear {
                Broadcaster.shared.splitViewVisibility = .all
            }
    }

    private func updateSidebarHandlingStatus() {
        guard OS.type != .macOS else {
            Broadcaster.shared.splitViewVisibility = .all
            return
        }
        switch orientation.orientation {
        case .landscape where !isCompact: Broadcaster.shared.splitViewVisibility = .all
        default: Broadcaster.shared.splitViewVisibility = .detailOnly
        }
    }
}
