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
        if !isOverCompact {
            ToolbarItem(placement: .cancellationAction) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? false
                )
            }
            .removeSharedBackgroundVisibility(bypassWhen: forceMenu ?? false)
        } else {
            // 仅在 iOS 18.0 ~ 18.3 故障期间触发，其余情形已改由 ContentView 派出 TabView。
            ToolbarItem(placement: .cancellationAction) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? true
                )
            }
        }
    }

    // MARK: Private

    @MainActor @ViewBuilder
    private func sharedToolbarNavPicker(allCases: Bool, isMenu: Bool = true) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        Picker("".description, selection: $this.rootPageNav) {
            ForEach(effectiveCases.filter(\.isExposed)) { navCase in
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
}
