// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaProfileView

public struct GachaProfileView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        poolPickerSection
        Section {
            GachaChartHorizontal(
                gpid: theVM.currentGPID,
                poolType: theVM.currentPoolType
            )?.environment(theVM)
            NavigationLink {
                GachaBigChartView()
                    .environment(theVM)
            } label: {
                Label(GachaBigChartView.navTitle, systemSymbol: .chartBarXaxis)
            }
        }
        GachaStatsSection(
            gpid: theVM.currentGPID,
            poolType: theVM.currentPoolType
        )?.environment(theVM)
        NavigationLink(GachaProfileDetailedListView.navTitle) {
            GachaProfileDetailedListView()
                .environment(theVM)
        }
        .disabled(theVM.taskState == .busy)
    }

    // MARK: Internal

    var availablePoolTypes: [GachaPoolExpressible] {
        guard let game = theVM.currentGPID?.game else { return [] }
        return GachaPoolExpressible.getKnownCases(by: game)
    }

    // MARK: Fileprivate

    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM

    @MainActor @ViewBuilder fileprivate var poolPickerSection: some View {
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
            } header: {
                Text("gachaKit.filter.options".i18nGachaKit).textCase(.none)
            }
        }
    }
}
