// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - AppRootPage

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
enum AppRootPage: CaseIterable, Identifiable, Sendable, Hashable {
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

    public static let allCases: [AppRootPage] = [
        .today,
        .showcaseDetail,
        .utils,
        .appSettings,
    ]

    public static let enabledSubCases: [AppRootPage] = [
        .showcaseDetail,
        .utils,
        .appSettings,
    ]

    public static var exposedCaseTags: [Int] {
        [1, 2, 3, 0]
    }

    public var id: Int { rootID }

    public var rootID: Int {
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

    public var label: some View {
        Label(title: { labelNameText }, icon: { icon })
    }
}

// MARK: - AppRootPageViewWrapper

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct AppRootPageViewWrapper: View {
    // MARK: Lifecycle

    public init(tab: AppRootPage) {
        self.tab = tab
    }

    // MARK: Public

    public var body: some View {
        switch tab {
        case .today:
            TodayTabPage()
                .tag(tab)
        // .tabItem { tab.label }
        case .showcaseDetail:
            DetailPortalTabPage()
                .tag(tab)
        // .tabItem { tab.label }
        case .utils:
            UtilsTabPage()
                .tag(tab)
        // .tabItem { tab.label }
        case .appSettings:
            AppSettingsTabPage()
                .tag(tab)
            // .tabItem { tab.label }
        }
    }

    // MARK: Private

    private let tab: AppRootPage
}
