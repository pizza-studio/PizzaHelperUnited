// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import EnkaDBModels
import PZBaseKit
import SwiftUI

// MARK: - CharSpecimen

@available(iOS 17.0, macCatalyst 17.0, *)
public struct CharSpecimen: Identifiable, Hashable, Sendable {
    // MARK: Public

    public let id: String

    @MainActor @ViewBuilder
    public func render(size: Double, cutType: IDPhotoView4HSR.IconType = .cutShoulder) -> some View {
        Group {
            if id.count == 4 {
                if let first = IDPhotoView4HSR(pid: id, size, cutType, forceRender: true) {
                    first
                } else {
                    IDPhotoFallbackView4HSR(pid: id, size, cutType)
                }
            } else {
                CharacterIconView(charID: id, size: size)
            }
        }.frame(width: size, height: size)
    }

    @MainActor @ViewBuilder
    public static func renderAllSpecimen(
        for game: Enka.GameType?,
        scroll: Bool,
        columns: Int,
        renderedColumnCount: Binding<Int>? = nil,
        supplementalIDs: (() -> [String])? = nil,
        viewRenderer: @escaping (CharSpecimen) -> some View
    )
        -> some View {
        let specimens = Self.allSpecimens(for: game, supplementalIDs: supplementalIDs?())
        let inner = StaggeredGrid(
            columns: columns,
            showsIndicators: !scroll,
            outerPadding: true,
            scroll: scroll,
            renderedColumnCount: renderedColumnCount,
            list: specimens
        ) { specimen in
            viewRenderer(specimen)
        }
        if scroll {
            ScrollView {
                inner.padding()
            }
        } else {
            inner
        }
    }

    // MARK: Internal

    static func allSpecimens(for game: Enka.GameType?, supplementalIDs: [String]? = nil) -> [Self] {
        var ids: [String] = []
        switch game {
        case .genshinImpact:
            let filtered: [[String]] = Enka.Sputnik.shared.db4GI.characters.compactMap { charID, char in
                // Drop duplicated anemo protagonist.
                if Protagonist(rawValue: Int(charID.prefix(8).description) ?? -114_514) != nil {
                    guard charID.count != 8 else { return nil }
                }
                let costume: (String, EnkaDBModelsGI.Costume)? = char.costumes?.first { _, costume in
                    !costume.icon.contains("CostumeWic")
                }
                var returnable = [charID]
                if let costume {
                    returnable.append("\(charID)_\(costume.0)")
                }
                return returnable
            }
            ids = filtered.reduce([], +)
        case .starRail:
            ids = Enka.Sputnik.shared.db4HSR.characters.keys.sorted()
        case .zenlessZone: break // 临时设定。
        case .none: break
        }
        ids += (supplementalIDs ?? [])
        return Set<String>(ids).sorted().map { Self(id: $0) }
    }
}

// MARK: - AllCharacterPhotoSpecimenViewPerGame

@available(iOS 17.0, macCatalyst 17.0, *)
public struct AllCharacterPhotoSpecimenViewPerGame: View {
    // MARK: Lifecycle

    public init(
        for game: Enka.GameType,
        scroll: Bool = true,
        supplementalIDs: (() -> [String])? = nil
    ) {
        self.scroll = scroll
        self.supplementalIDs = supplementalIDs?() ?? []
        self.game = game
    }

    // MARK: Public

    public var body: some View {
        coreBodyView
    }

    // MARK: Private

    private struct GridMetrics {
        let singleSize: Double
        let gridHeight: CGFloat
    }

    /// 首帧（尚未量到真实行宽）时，单行内容相对「清单列可用宽」被内缩的保守估计：
    /// 被 pushed 的畫面实测导航边距 71pt ＋ `Form` 行内缩 40pt。
    /// 单翼状态下实测可达 144pt（导航边距 84 ＋ 尾随 20 ＋ 行内缩 40），
    /// 故仅作首帧的保守值；真实值一律以 `reportListRowContentWidth()` 的实测结果为准。
    private static let listRowContentInsetDelta: CGFloat = 111

    /// 保证的单行内容左右内距。取 1 而非 0：0 会让系统把原厂 margin 一并撤掉，反而贴齐边缘。
    private static let listRowHorizontalMargin: CGFloat = 1

    /// `StaggeredGrid`（`outerPadding: true`）的内建间距与四周 padding 都是 10pt。
    private static let gridSpacing: CGFloat = 10

    /// 每一栏的理想最小宽度：用来决定栏数（沿用既有行为）。
    private static let idealColumnWidth: CGFloat = 120

    @State private var screenVM: ScreenVM = .shared
    @Environment(\.listRowContentWidth) private var listRowContentWidth: CGFloat?
    @State private var scroll: Bool
    @State private var game: Enka.GameType
    @State private var supplementalIDs: [String]

    /// `StaggeredGrid` 当下**实际已经摆出来**的栏数（由它回报，见其 `renderedColumnCount`）。
    @State private var renderedColumns: Int = 0

    private var specimenCount: Int {
        CharSpecimen.allSpecimens(for: game, supplementalIDs: supplementalIDs).count
    }

    /// 首帧的保守估计（真实值由 `reportListRowContentWidth()` 量到后经 `ScreenVM` 提交回来）。
    private var fallbackRowWidth: CGFloat {
        let derived = (screenVM.mainColumnCanvasSizeObserved.width) - Self.listRowContentInsetDelta
        return Swift.max(derived, 0)
    }

    /// 当前可用的行内容宽：优先用环境注入的实测值，其次用本页自己量到、已由 `ScreenVM` 提交回来的值，
    /// 都还没有（首帧）才用保守估计。
    ///
    /// 之所以要多一层退路：`\.listRowColumn` 的默认值恰好就是 `.mainColumn`，所以「本页回报到 main」
    /// 并不能证明本页确实落在该栏的环境子树内；实测（2026-10-08，iPhone Duo）本页的
    /// `\.listRowContentWidth` 恒为 nil，一律走 `fallbackRowWidth`，于是把固定内缩估计当成真实行宽。
    /// 该固定值在满版时偏窄（无碍），但在单翼／外萤幕等内缩变大的状态下会高估 30–50pt，
    /// 网格便以过宽的栏宽摆放固定尺寸的卡片，与邻栏重叠、并被画面右缘裁掉。
    private var currentRowWidth: CGFloat {
        if let listRowContentWidth, listRowContentWidth > 0 { return listRowContentWidth }
        if screenVM.mainColumnRowContentWidth > 0 { return screenVM.mainColumnRowContentWidth }
        return fallbackRowWidth
    }

    /// 依现在的行宽，应该分成几栏（交给 `StaggeredGrid`）。
    private var requestedColumns: Int {
        let contentWidth = Swift.max(currentRowWidth - 2 * Self.listRowHorizontalMargin, 0)
        return Swift.max(Int((contentWidth / Self.idealColumnWidth).rounded(.down)), 1)
    }

    /// 算卡片边长时该用的栏数：跟着「已摆出来的」结构走，而不是「将要摆的」。
    private var effectiveColumns: Int {
        renderedColumns > 0 ? renderedColumns : requestedColumns
    }

    /// 以 `reportListRowContentWidth()` 就地实测行内容宽度：它用贪心的零高 marker 量到「上级给的提案宽」，
    /// 不受网格自身溢出影响，因此不会形成测量回授；量到的值先 stage 进 `ScreenVM`，与该栏的
    /// `NavigationSplitView` 可见性在同一次排版状态提交里落定，所以旋转 / 铰链开合只会让本视图重排一次。
    @ViewBuilder private var coreBodyView: some View {
        let metrics = gridMetrics(columns: effectiveColumns)
        CharSpecimen.renderAllSpecimen(
            for: game,
            scroll: scroll,
            columns: requestedColumns,
            renderedColumnCount: $renderedColumns
        ) {
            supplementalIDs
        } viewRenderer: { specimen in
            specimen.render(size: metrics.singleSize, cutType: .cutShoulder)
        }
        .padding(.horizontal, Self.listRowHorizontalMargin)
        .frame(height: metrics.gridHeight)
        .reportListRowContentWidth()
    }

    /// 单个 specimen 的边长：必须与 `StaggeredGrid` 实际分配给每一栏的宽度完全相等，
    /// 否则固定尺寸的 specimen 会溢出自己的栏位、与邻栏的 specimen 互相重叠。
    ///
    /// `columns` 收的是 `effectiveColumns` 而非 `requestedColumns`：`StaggeredGrid` 的重排是
    /// 异步的（`Task.detached` 算完才回主线程），中间至少会有一帧仍是旧栏数。若边长跟着
    /// `requestedColumns` 先换，网格就会以旧栏数摆新尺寸的卡片而互相重叠；跟着「已摆出来的」
    /// 栏数算，边长永远落后或等于结构，最坏只是暂时留白。
    private func gridMetrics(columns: Int) -> GridMetrics {
        let contentWidth = Swift.max(currentRowWidth - 2 * Self.listRowHorizontalMargin, 0)
        let usable = Swift.max(contentWidth - 2 * Self.gridSpacing, 0)
        let slots = CGFloat(Swift.max(columns, 1))
        let slotWidth = (usable - Self.gridSpacing * (slots - 1)) / slots
        let singleSize = Swift.max(Double(slotWidth.rounded(.down)), 1)
        let rows = Swift.max(Int((Double(specimenCount) / Double(slots)).rounded(.up)), 1)
        let innerHeight = CGFloat(rows) * CGFloat(singleSize) + CGFloat(rows - 1) * Self.gridSpacing
        let extraPadding: CGFloat = scroll ? 16 * 2 : 0
        let gridHeight = innerHeight + 2 * Self.gridSpacing + extraPadding
        return .init(singleSize: singleSize, gridHeight: gridHeight)
    }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
struct CharacterPhotoSpecimenViewPerGame_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Form {
                TabView {
                    AllCharacterPhotoSpecimenViewPerGame(for: .starRail, scroll: false) {
                        ["1218", "1221", "1224"]
                    }.tabItem { Text(verbatim: "HSR") }
                    AllCharacterPhotoSpecimenViewPerGame(for: .genshinImpact, scroll: false)
                        .tabItem { Text(verbatim: "GI") }
                }
            }
            .formStyle(.grouped).disableFocusable()
        }
        .frame(height: 600)
    }
}

#endif
