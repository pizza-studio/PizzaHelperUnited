// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import GachaKit
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - ContentView

public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        TabView(selection: $tabNavVM.rootTabNav.animation()) {
            ForEach(TabNav.allCases) { navCase in
                if navCase.isExposed {
                    navCase
                }
            }
        }
        .onChange(of: accounts) {
            Task { @MainActor in
                await PZProfileActor.shared.syncAllDataToUserDefaults()
            }
        }
        #if targetEnvironment(macCatalyst)
        .apply { theContent in
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
        #endif
        .tint(tintForCurrentTab)
        .onChange(of: tabNavVM.rootTabNav.rootID) {
            simpleTaptic(type: .selection)
        }
        .environment(GachaVM.shared)
    }

    // MARK: Internal

    enum TabNav: View, CaseIterable, Identifiable, Sendable, Hashable {
        case today
        case showcaseDetail
        case utils
        case appSettings(AppSettingsTabPage.Nav? = nil)

        // MARK: Lifecycle

        public init?(rootID: Int) {
            let matched = Self.allCases.first { $0.rootID == rootID }
            guard let matched else { return nil }
            self = matched
        }

        // MARK: Public

        nonisolated public var id: Int {
            switch self {
            case let .appSettings(subNav): rootID + (subNav?.rawValue ?? 0) * 100
            default: rootID
            }
        }

        nonisolated public var rootID: Int {
            switch self {
            case .today: 1
            case .showcaseDetail: 2
            case .utils: 3
            case .appSettings: 0
            }
        }

        @ViewBuilder public var body: some View {
            switch self {
            case .today:
                TodayTabPage()
                    .tag(self) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .showcaseDetail:
                DetailPortalTabPage()
                    .tag(self) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .utils:
                UtilsTabPage()
                    .tag(self) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case let .appSettings(subNav):
                AppSettingsTabPage(nav: subNav)
                    .tag(self) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            }
        }

        public var label: some View {
            switch self {
            case .today: Label("tab.today".i18nPZHelper, systemSymbol: .windshieldFrontAndWiperAndDrop)
            case .showcaseDetail: Label("tab.details".i18nPZHelper, systemSymbol: .personTextRectangleFill)
            case .utils: Label("tab.utils".i18nPZHelper, systemSymbol: .shippingboxFill)
            case .appSettings: Label("tab.settings".i18nPZHelper, systemSymbol: .wrenchAndScrewdriverFill)
            }
        }

        // MARK: Internal

        nonisolated static let allCases: [ContentView.TabNav] = [
            .today,
            .showcaseDetail,
            .utils,
            .appSettings(nil),
        ]

        static var exposedCaseTags: [Int] {
            [1, 2, 3, 0]
        }

        var isExposed: Bool {
            Self.exposedCaseTags.contains(rootID)
        }
    }

    @Query(sort: \PZProfileMO.priority) var accounts: [PZProfileMO]

    @Default(.appTabIndex) var appIndex: Int

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @StateObject private var tabNavVM = GlobalNavVM.shared

    private var tintForCurrentTab: Color {
        switch TabNav(rootID: tabNavVM.rootTabNav.rootID) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }
}

// MARK: - GlobalNavVM

@Observable @MainActor
final class GlobalNavVM: Sendable, ObservableObject {
    static let shared = GlobalNavVM()

    var rootTabNav: ContentView.TabNav = {
        let initSelection: Int = {
            guard Defaults[.restoreTabOnLaunching] else { return 1 }
            let allBaseID = ContentView.TabNav.allCases.map(\.id)
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
}
