// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import GachaKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        TabView(selection: index) {
            ForEach(NavItems.allCases) { navCase in
                if navCase.isExposed {
                    navCase
                }
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
        .onChange(of: selection) {
            simpleTaptic(type: .selection)
        }
        .environment(GachaVM.shared)
        // .initializeApp()
    }

    // MARK: Internal

    enum NavItems: Int, View, CaseIterable, Identifiable, Sendable {
        case today = 1
        case showcaseDetail = 2
        case utils = 3
        case appSettings = 0

        // MARK: Public

        @MainActor @ViewBuilder public var body: some View {
            switch self {
            case .today:
                TodayTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .showcaseDetail:
                DetailPortalTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .utils:
                UtilsTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            case .appSettings:
                AppSettingsTabPage()
                    .tag(rawValue) // .toolbarBackground(.thinMaterial, for: .tabBar)
                    .tabItem { label }
            }
        }

        @MainActor @ViewBuilder public var label: some View {
            switch self {
            case .today: Label("tab.today".i18nPZHelper, systemSymbol: .windshieldFrontAndWiperAndDrop)
            case .showcaseDetail: Label("tab.details".i18nPZHelper, systemSymbol: .personTextRectangleFill)
            case .utils: Label("tab.utils".i18nPZHelper, systemSymbol: .shippingboxFill)
            case .appSettings: Label("tab.settings".i18nPZHelper, systemSymbol: .wrenchAndScrewdriverFill)
            }
        }

        // MARK: Internal

        static var exposedCaseTags: [Int] {
            [1, 2, 3, 0]
        }

        nonisolated var id: Int { rawValue }

        var isExposed: Bool {
            Self.exposedCaseTags.contains(rawValue)
        }
    }

    @Default(.appTabIndex) var appIndex: Int

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            if $0 != selection {
                Broadcaster.shared.stopRootTabTasks()
                if $0 == 1 {
                    Broadcaster.shared.todayTabDidSwitchTo()
                }
            }
            selection = $0
            appIndex = $0
            UserDefaults.baseSuite.synchronize()
        }
    ) }

    // MARK: Private

    @State private var selection: Int = {
        guard Defaults[.restoreTabOnLaunching] else { return 0 }
        guard NavItems.allCases.map(\.rawValue).contains(Defaults[.appTabIndex]) else { return 0 }
        return Defaults[.appTabIndex]
    }()

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext

    private var tintForCurrentTab: Color {
        switch NavItems(rawValue: selection) {
        case .today: Color.accessibilityAccent(colorScheme)
        case .showcaseDetail: Color.accessibilityAccent(colorScheme)
        default: .accentColor
        }
    }
}
