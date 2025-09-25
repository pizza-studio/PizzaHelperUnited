// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - GachaBigChartView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaBigChartView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle = "gachaKit.profile.bigChart".i18nGachaKit

    public var body: some View {
        NavigationStack {
            Form {
                contentFilterSection
                    .disabled(gachaVM.taskState == .busy)
                GachaChartVertical(
                    gpid: gachaVM.currentGPID,
                    poolType: gachaVM.currentPoolType
                )?.frame(width: containerWidth)
            }
            .formStyle(.grouped).disableFocusable()
            .environment(gachaVM)
            .animation(.easeIn(duration: 0.2), value: screenVM.mainColumnCanvasSizeObserved.width)
            .saturation(gachaVM.taskState == .busy ? 0 : 1)
            .navBarTitleDisplayMode(.large)
            .navigationTitle(gachaVM.currentGPIDTitle ?? Self.navTitle)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                        .environment(gachaVM)
                }
                if gachaVM.taskState == .busy {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                }
            }
        }
    }

    // MARK: Internal

    var availablePoolTypes: [GachaPoolExpressible] {
        guard let game = gachaVM.currentGPID?.game else { return [] }
        return GachaPoolExpressible.getKnownCases(by: game)
    }

    // MARK: Private

    @Environment(GachaVM.self) private var gachaVM
    @State private var screenVM: ScreenVM = .shared

    private var containerWidth: CGFloat {
        screenVM.mainColumnCanvasSizeObserved.width - 64
    }

    @ViewBuilder private var contentFilterSection: some View {
        if let theProfile = gachaVM.currentGPID {
            Section {
                let labelName = GachaPoolExpressible.getPoolFilterLabel(by: theProfile.game)
                @Bindable var gachaVM = gachaVM
                Picker(labelName, selection: $gachaVM.currentPoolType.animation()) {
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
