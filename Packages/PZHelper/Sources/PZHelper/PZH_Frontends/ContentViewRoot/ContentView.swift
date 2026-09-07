// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import GachaKit
import PZAccountKit
import PZBaseKit
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
        // TabView 不能嵌进 NavigationSplitView 的 detail 插槽——哪怕折叠成单栏，
        // LiquidGlass Tab Bar 仍会在冷启动时漏画未曾选中过的分页标签文字。
        // 故手机紧凑直向布局改用完全独立的顶层 TabView，不再共用 NavigationSplitView。
        if screenVM.isPhonePortraitSituation, !OS.isBuggyOS25Build {
            phoneTabBarContent
        } else {
            splitViewContent
        }
    }

    @ViewBuilder
    private var phoneTabBarContent: some View {
        nativeTabBarContent
            .react(to: rootNavVM.rootPageNav) { simpleTaptic(type: .medium) }
            .scrollEdgeHardened()
            .appTabBarVisibility(.visible)
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
            .environment(GachaVM.shared)
    }

    @ViewBuilder
    private var splitViewContent: some View {
        NavigationSplitView(
            columnVisibility: $screenVM.splitViewVisibility,
            preferredCompactColumn: $viewColumn
        ) {
            NavigationStack {
                TodayTabPage(wrappedByNavStack: false)
                    .scrollEdgeHardened()
                    .scrollContentBackground(.hidden)
                    .listRowMaterialBackground()
                    .listContainerBackground(thickMaterial: true)
                    .navBarTitleDisplayMode(.large)
            }
            .toolbar(removing: .sidebarToggle) // Remove toggle button
            #if !os(macOS)
                .toolbar(.hidden, for: .navigationBar) // Additional safeguard
            #endif
                .tint(Color.accessibilityAccent(colorScheme))
                .fontWidth(screenVM.actualSidebarWidthObserved < 350 ? .compressed : nil)
                .frame(width: OS.isAppKit ? sideBarWidth : nil)
                .trackCanvasSize(debounceDelay: 0.3) {
                    screenVM.handleTrackedSidebarCanvasSize($0)
                }
        } detail: {
            AppRootPageViewWrapper(tab: rootNavVM.rootPageNav)
                .scrollEdgeHardened()
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
                .trackCanvasSize(debounceDelay: 0.3) {
                    screenVM.handleTrackedMainColumnCanvasSize($0)
                }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(tintForCurrentTab)
        .apply(hookSidebarAndPageHandlers)
        .navigationSplitViewColumnWidth(sideBarWidth)
        .environment(GachaVM.shared)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @State private var rootNavVM = RootNavVM.shared
    @State private var broadcaster = Broadcaster.shared
    @State private var screenVM: ScreenVM = .shared
    @State private var viewColumn: NavigationSplitViewColumn = .content
    @Binding private var rootPageNavBinding: AppRootPage?

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

    /// `Tab(value:label:content:)` 是 iOS/macCatalyst 18、macOS 15 起才有的写法；
    /// 部署下限是 iOS 17，故该窄区间仍保留经典 `.tabItem` 写法兜底。
    @ViewBuilder
    private var nativeTabBarContent: some View {
        if #available(iOS 18.0, macCatalyst 18.0, macOS 15.0, *) {
            TabView(selection: $rootNavVM.rootPageNav) {
                if AppRootPage.today.isExposed {
                    Tab(value: AppRootPage.today) {
                        AppRootPageViewWrapper(tab: .today)
                    } label: {
                        AppRootPage.today.label
                    }
                }
                if AppRootPage.showcaseDetail.isExposed {
                    Tab(value: AppRootPage.showcaseDetail) {
                        AppRootPageViewWrapper(tab: .showcaseDetail)
                    } label: {
                        AppRootPage.showcaseDetail.label
                    }
                }
                if AppRootPage.utils.isExposed {
                    Tab(value: AppRootPage.utils) {
                        AppRootPageViewWrapper(tab: .utils)
                    } label: {
                        AppRootPage.utils.label
                    }
                }
                if AppRootPage.appSettings.isExposed {
                    Tab(value: AppRootPage.appSettings) {
                        AppRootPageViewWrapper(tab: .appSettings)
                    } label: {
                        AppRootPage.appSettings.label
                    }
                }
            }
        } else {
            TabView(selection: $rootNavVM.rootPageNav) {
                ForEach(AppRootPage.allCases.filter(\.isExposed)) { navCase in
                    AppRootPageViewWrapper(tab: navCase)
                        .tag(navCase)
                        .tabItem { navCase.label }
                }
            }
        }
    }

    @ViewBuilder
    private func hookSidebarAndPageHandlers(_ givenView: some View) -> some View {
        givenView
            .react(to: screenVM.hashForTracking, initial: true) {
                fixMainColumnPageIfNeeded()
            }
    }

    private func fixMainColumnPageIfNeeded() {
        if screenVM.isSidebarVisible, rootNavVM.rootPageNav == .today {
            rootPageNavBinding = .showcaseDetail
        }
    }
}
