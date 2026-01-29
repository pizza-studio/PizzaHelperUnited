// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - RootNavVM

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
final class RootNavVM {
    // MARK: Public

    public static let isAppKit = OS.type == .macOS && !OS.isCatalyst
    public static let shared = RootNavVM()

    public let screenVM: ScreenVM = .shared

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

    @ToolbarContentBuilder
    public func sharedRootPageSwitcherAsToolbarContent() -> some ToolbarContent {
        let allCases = !screenVM.isSidebarVisible
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        let maxLabelLength = effectiveCases.map(\.labelNameTextRaw.count).max()
        let forceMenu: Bool? = (maxLabelLength ?? 0) > 8 ? true : nil
        let isOverCompact = screenVM.isPhonePortraitSituation
        let placeAtTop = OS.isBuggyOS25Build || !isOverCompact || OS.type == .macOS
        #if os(macOS)
        let actualPlacement: ToolbarItemPlacement = .cancellationAction
        #else
        let actualPlacement: ToolbarItemPlacement = !placeAtTop ? .bottomBar : .cancellationAction
        #endif
        if !isOverCompact {
            ToolbarItem(placement: actualPlacement) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? false
                )
            }
            .removeSharedBackgroundVisibility(bypassWhen: forceMenu ?? false)
        } else if OS.isBuggyOS25Build {
            /// iOS 18.0 ~ 18.3 这四个版本号段对 bottom toolbar 的支援有问题，只能放弃处理。
            /// (此前试过 safeAreaInset 替代方案，仍无效。)
            ToolbarItem(placement: actualPlacement) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? true
                )
            }
        } else {
            ToolbarItem(placement: actualPlacement) {
                bottomTabBarForCompactLayout(allCases: !screenVM.isSidebarVisible)
            }
        }
    }

    // MARK: Private

    @MainActor @ViewBuilder
    private func sharedToolbarNavPicker(allCases: Bool, isMenu: Bool = true) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        Picker("".description, selection: $this.rootPageNav) {
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
                    .blurMaterialBackground(
                        enabled: !OS.liquidGlassThemeSuspected,
                        shape: .capsule,
                        interactive: true
                    )
            case false:
                currentContent
                    .pickerStyle(.segmented)
                    .labelStyle(.titleAndIcon)
            }
        }
        .fixedSize()
        .react(to: rootPageNav) {
            simpleTaptic(type: .medium)
        }
    }

    /// 该函式不处理 iOS 18.0 ~ 18.3 这个版本号段内的情形。
    @ViewBuilder
    private func bottomTabBarForCompactLayout(allCases: Bool) -> some View {
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *),
           OS.liquidGlassThemeSuspected {
            floatingBottomTabBar(effectiveCases: effectiveCases)
        } else {
            classicBottomTabBar(effectiveCases: effectiveCases)
                .react(to: rootPageNav) {
                    simpleTaptic(type: .medium)
                }
        }
    }

    /// iOS 26+ Liquid Glass Style 浮動膠囊 Tab Bar
    @available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *)
    @ViewBuilder
    private func floatingBottomTabBar(effectiveCases: [AppRootPage]) -> some View {
        @Bindable var this = self
        FloatingGlassTabBar(
            effectiveCases: effectiveCases,
            selection: $this.rootPageNav
        )
    }

    /// 經典 Tab Bar 樣式（iOS 25 及更早，但 iOS 18.0 ~ 18.3 除外）
    @ViewBuilder
    private func classicBottomTabBar(effectiveCases: [AppRootPage]) -> some View {
        HStack(spacing: 0) {
            ForEach(effectiveCases, id: \.self) { navCase in
                let isChosen: Bool = navCase == self.rootPageNav
                if navCase.isExposed {
                    Button {
                        Task { @MainActor [weak self] in
                            self?.rootPageNav = navCase
                        }
                    } label: {
                        VStack(spacing: 0) {
                            navCase.icon.frame(width: 28, height: 28)
                            navCase.labelNameText
                                .font(.footnote)
                                .padding(.bottom, 4)
                        }
                        .padding(.vertical, 4)
                        .fixedSize()
                        .labelStyle(.titleAndIcon)
                        .fontWidth(.compressed)
                        .fontWeight(isChosen ? .bold : .regular)
                        .foregroundStyle(!isChosen ? Color.secondary : Color.accentColor)
                        .padding()
                        .contentShape(.rect)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .id(navCase)
                }
            }
        }
        .frame(minHeight: 50, maxHeight: 54)
        .shadow(radius: 4)
    }
}
