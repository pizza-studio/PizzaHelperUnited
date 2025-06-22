// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

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

    nonisolated public var id: Int { rootID }

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
        case .appSettings:
            AppSettingsTabPage()
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

    nonisolated static let allCases: [AppTabNav] = [
        .today,
        .showcaseDetail,
        .utils,
        .appSettings,
    ]

    static var exposedCaseTags: [Int] {
        [1, 2, 3, 0]
    }

    var isExposed: Bool {
        Self.exposedCaseTags.contains(rootID)
    }
}
