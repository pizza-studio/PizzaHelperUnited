// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - GachaExchangeView

@available(iOS 17.0, macCatalyst 17.0, *)
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

    public var body: some View {
        NavigationStack {
            Form {
                Group {
                    switch currentPage {
                    case .importData: GachaImportSections()
                    case .exportData: GachaExportSections()
                    }
                }
                .saturation(theVM.taskState == .busy ? 0 : 1)
                .disabled(theVM.taskState == .busy)
            }
            .formStyle(.grouped).disableFocusable()
            .navBarTitleDisplayMode(.large)
            .navigationTitle(currentPage.localizedTitleForNav)
            .toolbar {
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                }
                if !theVM.allGPIDs.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Picker("".description, selection: $currentPage.animation()) {
                            ForEach(Page.allCases) { currentCase in
                                Text(currentCase.localizedTitleForTabs).tag(currentCase)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                        .saturation(theVM.taskState == .busy ? 0 : 1)
                        .disabled(theVM.taskState == .busy)
                    }
                }
            }
            .react(to: theVM.hasGPID.wrappedValue, initial: true) { _, hasGPID in
                if !hasGPID, currentPage != .importData {
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

    // MARK: Private

    @State private var currentPage: Page = .exportData
    @State private var theVM: GachaVM = .shared
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaExchangeView {
    @ViewBuilder
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
                    if let name = nameIDMap[gpid.uidWithGame] ?? gpid.profileName {
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

// MARK: GachaExchangeView.GachaProfileDoppelPicker

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaExchangeView {
    public struct GachaProfileDoppelPicker: View {
        // MARK: Lifecycle

        public init(
            among sortedGPIDs: [GachaProfileID],
            chosenOnes: Binding<Set<GachaProfileID>>,
            nameIDMap: [String: String] = [:]
        ) {
            self.sortedGPIDs = sortedGPIDs
            self.nameIDMap = nameIDMap
            self._specifiedProfiles = chosenOnes
        }

        // MARK: Public

        public var body: some View {
            ForEach(sortedGPIDs) { gpid in
                Toggle(
                    isOn: toggleBinding(for: gpid).animation()
                ) {
                    GachaExchangeView.drawGPID(
                        gpid,
                        nameIDMap: nameIDMap,
                        isChosen: specifiedProfiles.contains(gpid)
                    ).tag(gpid)
                }
            }
        }

        // MARK: Private

        @Binding private var specifiedProfiles: Set<GachaProfileID>

        private let sortedGPIDs: [GachaProfileID]
        private let nameIDMap: [String: String]

        private func toggleBinding(for profile: GachaProfileID) -> Binding<Bool> {
            .init {
                specifiedProfiles.contains(profile)
            } set: { newValue in
                switch newValue {
                case true: specifiedProfiles.insert(profile)
                case false: specifiedProfiles.remove(profile)
                }
            }
        }
    }
}
