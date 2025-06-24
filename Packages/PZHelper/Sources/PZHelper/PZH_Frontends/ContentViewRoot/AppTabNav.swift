// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: Internal

enum AppTabNav: View, CaseIterable, Identifiable, Sendable, Hashable {
    case today
    case showcaseDetail
    case utils
    case appSettings

    // MARK: Lifecycle

    public init?(rootID: Int) {
        let matched = Self.allCases.first { $0.rootID == rootID }
        guard let matched else { return nil }
        self = matched
    }

    // MARK: Public

    nonisolated public static let allCases: [AppTabNav] = [
        .today,
        .showcaseDetail,
        .utils,
        .appSettings,
    ]

    nonisolated public static let enabledSubCases: [AppTabNav] = [
        .showcaseDetail,
        .utils,
        .appSettings,
    ]

    public static var exposedCaseTags: [Int] {
        [1, 2, 3, 0]
    }

    nonisolated public var id: Int { rootID }

    nonisolated public var rootID: Int {
        switch self {
        case .today: 1
        case .showcaseDetail: 2
        case .utils: 3
        case .appSettings: 0
        }
    }

    public var labelNameText: Text {
        switch self {
        case .today: Text("tab.today".i18nPZHelper)
        case .showcaseDetail: Text("tab.details".i18nPZHelper)
        case .utils: Text("tab.utils".i18nPZHelper)
        case .appSettings: Text("tab.settings".i18nPZHelper)
        }
    }

    public var icon: Image {
        switch self {
        case .today: Image(systemSymbol: .windshieldFrontAndWiperAndDrop)
        case .showcaseDetail: Image(systemSymbol: .personTextRectangleFill)
        case .utils: Image(systemSymbol: .shippingboxFill)
        case .appSettings: Image(systemSymbol: .wrenchAndScrewdriverFill)
        }
    }

    public var isExposed: Bool {
        Self.exposedCaseTags.contains(rootID)
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
        case .appSettings:
            AppSettingsTabPage()
                .tag(self) // .toolbarBackground(.thinMaterial, for: .tabBar)
                .tabItem { label }
        }
    }

    public var label: some View {
        Label(title: { labelNameText }, icon: { icon })
    }
}
