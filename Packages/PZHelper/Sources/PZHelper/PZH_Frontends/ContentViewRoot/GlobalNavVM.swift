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

    public static let isAppKit = OS.type == .macOS && !OS.isCatalyst
    public static let shared = GlobalNavVM()

    public var isCompact: Bool = OS.type == .iPhoneOS
    public var isSidebarVisible: Bool = OS.type != .iPhoneOS
    public var windowSizeObserved: CGSize = .init(width: 375, height: 667)

    public var rootTabNavBindingNullable: Binding<AppTabNav?> {
        .init(
            get: {
                self.rootTabNav
            },
            set: { newValue in
                self.rootTabNav = newValue ?? .today
            }
        )
    }

    public var rootTabNav: AppTabNav = {
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

    @ViewBuilder public var gotoSettingsButtonIfAppropriate: some View {
        if rootTabNav != .appSettings {
            Button {
                withAnimation {
                    self.rootTabNav = .appSettings
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
        ToolbarItem(placement: isCompact ? .bottomBar : .cancellationAction) {
            if !isCompact {
                sharedToolbarNavPicker(
                    allCases: !isSidebarVisible,
                    isMenu: false
                )
            } else {
                bottomTabBarForCompactLayout(allCases: !isSidebarVisible)
            }
        }
    }

    // MARK: Private

    @MainActor @ViewBuilder
    private func sharedToolbarNavPicker(allCases: Bool, isMenu: Bool = true) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppTabNav.enabledSubCases : AppTabNav.allCases
        Picker("".description, selection: $this.rootTabNav.animation()) {
            ForEach(effectiveCases) { navCase in
                if navCase.isExposed {
                    let isChosen: Bool = navCase == self.rootTabNav
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
        let effectiveCases = !allCases ? AppTabNav.enabledSubCases : AppTabNav.allCases
        HStack(spacing: 0) {
            ForEach(effectiveCases) { navCase in
                let isChosen: Bool = navCase == self.rootTabNav
                if navCase.isExposed {
                    Button {
                        withAnimation(.easeInOut) {
                            self.rootTabNav = navCase
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
