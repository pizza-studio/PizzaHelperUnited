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
            columnVisibility: .constant(.all),
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
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        tabNavVM.sharedToolbarNavPicker(
                            allCases: horizontalSizeClass == .compact
                        )
                    }
                }
                .tint(tintForCurrentTab)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(tintForCurrentTab)
        .onChange(of: horizontalSizeClass, initial: true) { oldValue, newValue in
            if oldValue == .compact, newValue != .compact, tabNavVM.rootTabNav == .today {
                rootTabNavBinding.wrappedValue = .showcaseDetail
            }
        }
        .navigationSplitViewColumnWidth(sideBarWidth)
        .appTabBarVisibility(.visible)
        .environment(GachaVM.shared)
    }

    // MARK: Internal

    let rootTabNavBinding: Binding<AppTabNav?>

    @Default(.appTabIndex) var appIndex: Int

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var appTabVM = AppTabBarVM.shared
    @State private var viewColumn: NavigationSplitViewColumn = .content

    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

    private var sideBarWidth: CGFloat { 375 }

    private var tintForCurrentTab: Color {
        switch AppTabNav(rootID: tabNavVM.rootTabNav.rootID) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }
}
