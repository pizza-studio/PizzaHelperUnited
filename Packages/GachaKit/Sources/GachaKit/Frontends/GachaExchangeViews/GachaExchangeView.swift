// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftData
import SwiftUI

public struct GachaExchangeView: View {
    // MARK: Public

    public enum Page: String, Sendable, CaseIterable, Identifiable {
        case exportData
        case importData

        // MARK: Public

        public var id: String { rawValue }

        public var localizedTitleForTabs: String {
            "gachaKit.exchange.tabTitle.\(rawValue)".i18nGachaKit
        }

        public var localizedTitleForNav: String {
            "gachaKit.exchange.navTitle.\(rawValue)".i18nGachaKit
        }
    }

    @MainActor public var body: some View {
        NavigationStack {
            Form {
                Group {
                    switch currentPage {
                    case .importData: GachaImportSections()
                    case .exportData: GachaExportSections()
                    }
                }
                .environment(theVM)
                .disabled(theVM.taskState == .busy)
                .saturation(theVM.taskState == .busy ? 0 : 1)
            }
            .formStyle(.grouped)
            .navBarTitleDisplayMode(.large)
            .navigationTitle(currentPage.localizedTitleForNav)
            .toolbar {
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
                }
                if !pzGachaProfileIDs.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Picker("".description, selection: $currentPage.animation()) {
                            ForEach(Page.allCases) { currentCase in
                                Text(currentCase.localizedTitleForTabs).tag(currentCase)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(theVM.taskState == .busy)
                        .saturation(theVM.taskState == .busy ? 0 : 1)
                    }
                }
            }
            .onChange(of: pzGachaProfileIDs.count, initial: true) { _, newValue in
                if newValue == 0, currentPage != .importData {
                    currentPage = .importData
                }
            }
        }
    }

    // MARK: Fileprivate

    @State fileprivate var currentPage: Page = .exportData
    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM
}
