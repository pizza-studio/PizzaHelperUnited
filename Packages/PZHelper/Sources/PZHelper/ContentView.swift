// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

@MainActor
public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        TabView(selection: index) {
            ShowCaseQueryTabPage()
                .tag(0) // .toolbarBackground(.thinMaterial, for: .tabBar)
                .tabItem {
                    Label {
                        Text("tab.query", bundle: .module)
                    } icon: {
                        Image(systemSymbol: .magnifyingglassCircleFill)
                    }
                }
        }
        .tint(tintForCurrentTab)
        .onChange(of: selection) { _, _ in
            feedbackGenerator.selectionChanged()
        }
        // .initializeApp()
    }

    // MARK: Internal

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            selection = $0
            Defaults[.appTabIndex] = $0
            UserDefaults.baseSuite.synchronize()
        }
    ) }

    // MARK: Private

    @State private var selection: Int = {
        guard Defaults[.restoreTabOnLaunching] else { return 0 }
        guard (0 ..< 3).contains(Defaults[.appTabIndex]) else { return 0 }
        return Defaults[.appTabIndex]
    }()

    @Environment(\.colorScheme) private var colorScheme

    private let feedbackGenerator = UISelectionFeedbackGenerator()

    private var tintForCurrentTab: Color {
        .accentColor
        // switch selection {
        // case 0, 1: return .accessibilityAccent(colorScheme)
        // default: return .accentColor
        // }
    }
}
