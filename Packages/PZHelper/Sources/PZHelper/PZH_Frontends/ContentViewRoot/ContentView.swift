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

@available(iOS 17.0, macCatalyst 17.0, *)
public struct ContentView: View {
    // MARK: Lifecycle

    public init() {
        self._rootPageNavBinding = RootNavVM.shared.rootPageNavBindingNullable
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
                .fontWidth(screenVM.actualSidebarWidthObserved < 350 ? .compressed : nil)
                .trackCanvasSize(debounceDelay: 0.3) {
                    let existingWidth = screenVM.actualSidebarWidthObserved
                    let newValue = $0.width.rounded(.up)
                    guard existingWidth != newValue else { return }
                    screenVM.actualSidebarWidthObserved = newValue
                }
        } detail: {
            AppRootPageViewWrapper(tab: rootNavVM.rootPageNav)
                .appTabBarVisibility(.visible)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    rootNavVM.sharedRootPageSwitcherAsToolbarContent()
                }
                .tint(tintForCurrentTab)
                .apply { mainColumnContent in
                    if screenVM.isExtremeCompact {
                        mainColumnContent
                            .fontWidth(.compressed)
                            .navigationTitle(rootNavVM.rootPageNav.labelNameText)
                    } else {
                        mainColumnContent
                    }
                }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(tintForCurrentTab)
        .apply { currentContent in
            hookSidebarAndPageHandlers(currentContent)
                .onChange(of: rootNavVM.rootPageNav) {
                    simpleTaptic(type: .medium)
                }
        }
        .navigationSplitViewColumnWidth(sideBarWidth)
        .environment(GachaVM.shared)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @State private var rootNavVM = RootNavVM.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @State private var screenVM = ScreenVM.shared
    @State private var viewColumn: NavigationSplitViewColumn = .content
    @Binding private var rootPageNavBinding: AppRootPage?

    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

    private var sideBarWidth: CGFloat { 375 }

    private var effectiveAppNavCases: [AppRootPage] {
        screenVM.isSidebarVisible ? AppRootPage.enabledSubCases : AppRootPage.allCases
    }

    private var tintForCurrentTab: Color {
        switch AppRootPage(rootID: rootNavVM.rootPageNav.rootID) {
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
        if screenVM.isSidebarVisible, rootNavVM.rootPageNav == .today {
            rootPageNavBinding = .showcaseDetail
        }
    }
}
