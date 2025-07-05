// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GachaProfileView

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct GachaProfileView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        poolPickerSection
        if let gpid = theVM.currentGPID {
            GachaEntryExpiredRow(alwaysVisible: false, games: [gpid.game])
        }
        Section {
            if theVM.taskState == .busy {
                InfiniteProgressBar().id(UUID())
            } else {
                GachaChartHorizontal(
                    gpid: theVM.currentGPID,
                    poolType: theVM.currentPoolType
                )?.environment(theVM)
            }
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
        .saturation(theVM.taskState == .busy ? 0 : 1)
        .disabled(theVM.taskState == .busy)
    }

    // MARK: Internal

    var availablePoolTypes: [GachaPoolExpressible] {
        guard let game = theVM.currentGPID?.game else { return [] }
        return GachaPoolExpressible.getKnownCases(by: game)
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM

    @ViewBuilder private var poolPickerSection: some View {
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
                Text("gachaKit.filter.options", bundle: .module).textCase(.none)
            }
        }
    }
}
