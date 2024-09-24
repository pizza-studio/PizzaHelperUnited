// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftData
import SwiftUI

// MARK: - GachaExchangeView

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
            .navigationBarBackButtonHidden(theVM.taskState == .busy)
            .animation(.default, value: theVM.taskState)
        }
        .onDisappear {
            theVM.currentSceneStep4Import = .chooseFormat
        }
    }

    // MARK: Fileprivate

    @State fileprivate var currentPage: Page = .exportData
    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM
}

extension GachaExchangeView {
    @MainActor @ViewBuilder
    public static func drawGPID(
        _ gpid: GachaProfileID,
        nameIDMap: [String: String],
        isChosen: Bool = false
    )
        -> some View {
        HStack {
            gpid.photoView.frame(width: 35, height: 35)
            HStack {
                Group {
                    if let name = nameIDMap[gpid.uidWithGame] {
                        VStack(alignment: .leading) {
                            Text(name)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(gpid.uidWithGame)
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .opacity(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Text(gpid.uidWithGame)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .foregroundStyle(isChosen ? Color.accentColor : .primary)
                Spacer()
            }
        }.padding(.vertical, 4)
    }
}
