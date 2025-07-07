// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GachaProfileView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaProfileDetailedListView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle = "gachaKit.profile.detailedList".i18nGachaKit

    public var body: some View {
        NavigationStack {
            Form {
                contentFilterSection
                    .disabled(theVM.taskState == .busy)
                ForEach(prefilteredEntries) { entry in
                    ZStack(alignment: .center) {
                        if chosenRarity != .rank5 {
                            entry.rarity.backgroundGradient.opacity(0.2)
                                .saturation(3)
                        }
                        GachaEntryBar(entry: entry, showDate: showDate)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .environment(theVM)
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .formStyle(.grouped)
            .navBarTitleDisplayMode(.large)
            .navigationTitle(theVM.currentGPIDTitle ?? Self.navTitle)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                        .environment(theVM)
                }
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    GachaExportToolbarButton(gpid: theVM.currentGPID)?
                        .environment(theVM)
                }
            }
        }
    }

    // MARK: Internal

    var availablePoolTypes: [GachaPoolExpressible] {
        guard let game = theVM.currentGPID?.game else { return [] }
        return GachaPoolExpressible.getKnownCases(by: game)
    }

    var prefilteredEntries: [GachaEntryExpressible] {
        guard let thePool = theVM.currentPoolType else { return [] }
        let cached = theVM.mappedEntriesByPools[thePool]
        return cached?.filter {
            $0.rarity.rawValue >= chosenRarity.rawValue
        } ?? []
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM
    @State private var showDate = false
    @State private var chosenRarity: GachaItemRankType = .rank5

    @ViewBuilder private var contentFilterSection: some View {
        if let theProfile = theVM.currentGPID {
            Section {
                let labelName = GachaPoolExpressible.getPoolFilterLabel(by: theProfile.game)
                @Bindable var theVM = theVM
                Picker(labelName, selection: $theVM.currentPoolType.animation()) {
                    ForEach(availablePoolTypes) { poolType in
                        let taggableValue = poolType as GachaPoolExpressible?
                        Text(poolType.localizedTitle).tag(taggableValue)
                    }
                }
                Picker("gachaKit.filter.rarity".i18nGachaKit, selection: $chosenRarity.animation()) {
                    ForEach(GachaItemRankType.allCases.reversed()) { rankValue in
                        let labelText = switch rankValue {
                        case .rank5: "★★★★★"
                        case .rank4: "★4 ★5"
                        case .rank3: "★3 ★4 ★5"
                        }
                        Text(labelText).tag(rankValue)
                    }
                }
                Toggle("gachaKit.filter.showDate".i18nGachaKit, isOn: $showDate.animation())
                GachaEntryExpiredRow(alwaysVisible: false, games: [theProfile.game])
            } header: {
                Text("gachaKit.filter.options", bundle: .module).textCase(.none)
            }
        }
    }
}
