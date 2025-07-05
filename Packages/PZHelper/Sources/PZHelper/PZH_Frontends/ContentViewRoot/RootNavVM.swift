// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - RootNavVM

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@Observable @MainActor
final class RootNavVM: Sendable, ObservableObject {
    // MARK: Public

    public static let isAppKit = OS.type == .macOS && !OS.isCatalyst
    public static let shared = RootNavVM()

    public let screenVM = ScreenVM.shared

    public var rootPageNav: AppRootPage = {
        let initSelection: Int = {
            guard Defaults[.restoreTabOnLaunching] else { return 1 }
            let allBaseID = AppRootPage.allCases.map(\.id)
            guard allBaseID.contains(Defaults[.appTabIndex]) else { return 1 }
            return Defaults[.appTabIndex]
        }()
        return .init(rootID: initSelection) ?? .today
    }() {
        willSet {
            guard rootPageNav != newValue else { return }
            Defaults[.appTabIndex] = newValue.rootID
            UserDefaults.baseSuite.synchronize()
            Broadcaster.shared.stopRootTabTasks()
            if newValue == .today {
                Broadcaster.shared.todayTabDidSwitchTo()
            }
        }
    }

    public var rootPageNavBindingNullable: Binding<AppRootPage?> {
        .init(
            get: {
                self.rootPageNav
            },
            set: { newValue in
                self.rootPageNav = newValue ?? .today
            }
        )
    }

    @ViewBuilder public var gotoSettingsButtonIfAppropriate: some View {
        if rootPageNav != .appSettings {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.rootPageNav = .appSettings
                }
            } label: {
                Text("app.dailynote.noCard.switchToSettingsPage".i18nPZHelper)
                    .fontWidth(.condensed)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.green)
            .listRowMaterialBackground()
        }
    }

    @ViewBuilder
    public func iOSBottomTabBarForBuggyOS25ReleasesOn() -> some View {
        #if !(os(macOS) && !targetEnvironment(macCatalyst))
        let isOverCompact = screenVM.isHorizontallyCompact && screenVM.windowSizeObserved
            .width <= 440
        if OS.isBuggyOS25Build, isOverCompact {
            bottomTabBarForCompactLayout(allCases: !screenVM.isSidebarVisible)
                .blurMaterialBackground()
                .shadow(radius: 4)
        }
        #endif
    }

    @ToolbarContentBuilder
    public func sharedRootPageSwitcherAsToolbarContent() -> some ToolbarContent {
        #if os(macOS) && !targetEnvironment(macCatalyst)
        ToolbarItem(placement: .cancellationAction) {
            sharedToolbarNavPicker(
                allCases: !screenVM.isSidebarVisible,
                isMenu: false
            )
        }
        #else
        /// 440 是 iPhone 16 Pro Max 的荧幕画布尺寸。
        let isOverCompact = screenVM.isHorizontallyCompact && screenVM.windowSizeObserved
            .width <= 440
        let placeAtTop = !(isOverCompact && !OS.isBuggyOS25Build)
        ToolbarItem(placement: !placeAtTop ? .bottomBar : .cancellationAction) {
            if !isOverCompact {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: false
                )
            } else if OS.isBuggyOS25Build {
                // NOTHING. We use non-toolbar approaches for such case.
            } else {
                bottomTabBarForCompactLayout(allCases: !screenVM.isSidebarVisible)
            }
        }
        #endif
    }

    // MARK: Private

    @MainActor @ViewBuilder
    private func sharedToolbarNavPicker(allCases: Bool, isMenu: Bool = true) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        Picker(
            "".description,
            selection: $this.rootPageNav.animation(.easeInOut(duration: 0.2))
        ) {
            ForEach(effectiveCases) { navCase in
                if navCase.isExposed {
                    let isChosen: Bool = navCase == self.rootPageNav
                    switch isMenu {
                    case true:
                        VStack(alignment: .center) {
                            navCase.icon
                            navCase.labelNameText
                                .fontWidth(.compressed)
                                .fontWeight(isChosen ? .bold : .regular)
                                .textCase(.uppercase)
                        }
                        .tag(navCase)
                    case false:
                        navCase.label
                            .tag(navCase)
                    }
                }
            }
        }
        .labelsHidden()
        .apply { currentContent in
            switch isMenu {
            case true:
                currentContent
                    .pickerStyle(.menu)
                    .blurMaterialBackground(enabled: !OS.liquidGlassThemeSuspected)
                    .clipShape(.capsule)
            case false:
                currentContent
                    .pickerStyle(.segmented)
                    .labelStyle(.titleAndIcon)
            }
        }
        .fixedSize()
    }

    @ViewBuilder
    private func bottomTabBarForCompactLayout(allCases: Bool) -> some View {
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        HStack(spacing: 0) {
            ForEach(effectiveCases) { navCase in
                let isChosen: Bool = navCase == self.rootPageNav
                if navCase.isExposed {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.rootPageNav = navCase
                        }
                    } label: {
                        VStack(spacing: 0) {
                            navCase.icon.frame(width: 30, height: 30)
                            navCase.labelNameText
                                .font(.footnote)
                                .padding(.bottom, OS.liquidGlassThemeSuspected ? 0 : 4)
                        }
                        .padding(.vertical, 4)
                        .fixedSize()
                        .labelStyle(.titleAndIcon)
                        .fontWidth(.compressed)
                        .fontWeight(isChosen ? .bold : .regular)
                        .foregroundStyle(isChosen ? Color.accentColor : .secondary)
                        .padding()
                        .contentShape(.rect)
                        .frame(maxWidth: OS.liquidGlassThemeSuspected ? nil : .infinity)
                    }
                    .buttonStyle(.plain)
                    .id(navCase)
                }
            }
        }
        .frame(height: 50)
    }
}
