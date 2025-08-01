// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GachaProfileView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaProfileView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        if let gpid = theVM.currentGPID {
            GMDBExpiredRow(alwaysVisible: false, games: [gpid.game])
        }
        Section {
            poolPicker
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

    @ViewBuilder private var poolPicker: some View {
        if let theProfile = theVM.currentGPID {
            let labelName = GachaPoolExpressible.getPoolFilterLabel(by: theProfile.game)
            @Bindable var theVM = theVM
            LabeledContent {
                Picker("".description, selection: $theVM.currentPoolType.animation()) {
                    ForEach(availablePoolTypes) { poolType in
                        let taggableValue = poolType as GachaPoolExpressible?
                        Text(poolType.localizedTitle).tag(taggableValue)
                    }
                }
                .labelsHidden()
            } label: {
                LabeledContent {
                    Text(verbatim: labelName)
                } label: {
                    Image(systemSymbol: .line3HorizontalDecreaseCircle)
                }
                .fixedSize()
            }
        }
    }
}
