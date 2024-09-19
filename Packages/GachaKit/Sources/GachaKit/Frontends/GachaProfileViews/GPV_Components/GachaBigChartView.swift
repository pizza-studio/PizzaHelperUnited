// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - GachaBigChartView

public struct GachaBigChartView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle = "gachaKit.profile.bigChart".i18nGachaKit

    @MainActor public var body: some View {
        NavigationStack {
            Form {
                contentFilterSection
                    .disabled(theVM.taskState == .busy)
                GachaChartVertical(
                    gpid: theVM.currentGPID,
                    poolType: theVM.currentPoolType
                )?.environment(theVM)
            }
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .formStyle(.grouped)
            .navBarTitleDisplayMode(.large)
            .navigationTitle(theVM.currentGPIDTitle ?? Self.navTitle)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                }
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
                }
            }
        }
    }

    // MARK: Internal

    var availablePoolTypes: [GachaPoolExpressible] {
        guard let game = theVM.currentGPID?.game else { return [] }
        return GachaPoolExpressible.getKnownCases(by: game)
    }

    var filteredEntries: [GachaEntryExpressible] {
        filteredEntriesWithDrawCount.map(\.entry)
    }

    var filteredEntriesWithDrawCount: [(entry: GachaEntryExpressible, drawCount: Int)] {
        let cachedEntries = theVM.cachedEntries.filter {
            $0.pool == theVM.currentPoolType
        }
        let drawCounts = cachedEntries.drawCounts
        let zippedPairs: [(entry: GachaEntryExpressible, drawCount: Int)] = Array(
            zip(cachedEntries, drawCounts)
        )
        return zippedPairs.filter {
            $0.entry.rarity == .rank5
        }
    }

    // MARK: Fileprivate

    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM

    @MainActor @ViewBuilder fileprivate var contentFilterSection: some View {
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
