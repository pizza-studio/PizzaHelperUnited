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
                if let gachaChart = GachaChartVertical(
                    gpid: gachaVM.currentGPID,
                    poolType: gachaVM.currentPoolType
                ) {
                    gachaChart
                        .padding(.horizontal, Self.listRowHorizontalMargin)
                }
            }
            .formStyle(.grouped).disableFocusable()
            .environment(gachaVM)
            .animation(.easeIn(duration: 0.2), value: containerWidth)
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
                        WinUI3ProgressRing()
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

    /// 单行内容相对「清单列基准宽」被内缩的量：被 pushed 的畫面实测导航边距 71pt ＋ `Form` 行内缩 40pt。
    private static let listRowContentInsetDelta: CGFloat = 111

    /// 保证的单行内容左右内距。取 1 而非 0：0 会让系统把原厂 margin 一并撤掉，反而贴齐边缘。
    private static let listRowHorizontalMargin: CGFloat = 1

    @State private var gachaVM: GachaVM = .shared
    @State private var screenVM: ScreenVM = .shared
    @Environment(\.listRowContentWidth) private var listRowContentWidth: CGFloat?

    /// 本页可用的行内容宽。只用于 :35 的动画触发值：图表自身内含 `GeometryReader` 会就地量宽，
    /// 因此本视图不该对图表再加上限（rotation 后上限会停留在旧方向，反而把图表夹窄）。
    private var containerWidth: CGFloat {
        screenVM.resolvedListRowContentWidth(
            injected: listRowContentWidth,
            canvasInset: Self.listRowContentInsetDelta
        )
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
                Text("gachaKit.filter.options", bundle: .currentSPM).textCase(.none)
            }
        }
    }
}
