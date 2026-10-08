// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Combine
import SwiftUI

#if !os(watchOS)

// MARK: - StaggeredGrid

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
public struct StaggeredGrid<Content: View, T: Identifiable & Equatable & Sendable>: View {
    // MARK: Lifecycle

    // MARK: - Initialization

    public init(
        columns: Int,
        scrollAxis: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        horizontalSpacing: CGFloat = 10,
        verticalSpacing: CGFloat = 10,
        padding: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10),
        alignment: VerticalAlignment = .top,
        renderedColumnCount: Binding<Int>? = nil,
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.columns = Swift.max(1, columns)
        self.scrollAxis = scrollAxis
        self.showsIndicators = showsIndicators
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.padding = padding
        self.alignment = alignment
        self.content = content
        self.list = list
        self.renderedColumnCount = renderedColumnCount
        self._vm = .init(wrappedValue: StaggeredGridVM(list: list, columns: columns))
    }

    // MARK: Public

    // MARK: - Body

    public var body: some View {
        Group {
            let axisSet = scrollAxis.isEmpty ? Axis.Set([.vertical]) : scrollAxis
            ScrollView(axisSet, showsIndicators: showsIndicators && !scrollAxis.isEmpty) {
                innerContent
            }
            .apply { scrollView in
                if #available(iOS 16.0, macCatalyst 16.0, *) {
                    scrollView.scrollDisabled(scrollAxis.isEmpty)
                } else {
                    scrollView
                }
            }
        }
        .react(to: list) { _, newList in
            vm.updateGridArray(list: newList, columns: columns)
        }
        // - Important: `initial: true` 是这条通知链的必要环节，不能省。
        //
        //   栏数变动的那一刻，若这个视图没有重算 body，`.react(to: columns)` 的通知就会漏接；
        //   而 `vm` 是 `@State`，会跟着视图存活下来，栏数从此**永远**停在旧值——这正是
        //   「一开始 viewport 外的内容」永远少一栏的成因（离屏列被 `List` 保留、不保证重算）。
        //
        //   `initial: true` 让视图每次实体化（含被 `List` 回收后重新出现）都先校对一次：栏数
        //   对不上就补做重排。补的仍然是**原来那条动画路径**（`updateGridArray` →
        //   `withAnimation`），所以动画形态与栏数正常的那些列完全一致，不是硬切。
        .react(to: columns, initial: true) { _, newColumns in
            guard newColumns > 0, !list.isEmpty else { return }
            guard vm.gridArray.count != newColumns else { return }
            vm.scheduleGridArrayUpdate(list: list, columns: newColumns)
        }
        .onAppear {
            if vm.gridArray.isEmpty, !list.isEmpty {
                vm.updateGridArray(list: list, columns: columns)
            }
        }
        .onChange(of: vm.gridArray.count, initial: true) { _, newCount in
            renderedColumnCount?.wrappedValue = newCount
        }
    }

    // MARK: Private

    @State private var vm: StaggeredGridVM<T>

    private let columns: Int
    private let scrollAxis: Axis.Set
    private let showsIndicators: Bool
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let padding: EdgeInsets
    private let alignment: VerticalAlignment
    private let content: (T) -> Content
    private let list: [T]

    /// 回报**当下实际摆出来的栏数**（`vm.gridArray.count`）。
    ///
    /// 呼叫方通常用同一个「清单列可用宽」同时算出栏数与卡片边长，于是尺寸与结构必须同步。
    /// 但重排是异步的（`Task.detached` 算完才回主线程），中间至少会有一帧还是旧栏数；此时若
    /// 卡片已换成新尺寸，网格就是以**旧栏数**摆放**新尺寸**的固定尺寸卡片，卡片会溢出栏位、
    /// 与邻栏重叠。有了这个回报，呼叫方可以让边长跟着**已摆出来的**栏数走：尺寸永远落后或
    /// 等于结构，最坏只是暂时留白，不可能重叠。
    private let renderedColumnCount: Binding<Int>?

    private var scroll: Bool { scrollAxis.isEmpty }

    @ViewBuilder private var innerContent: some View {
        HStack(alignment: alignment, spacing: horizontalSpacing) {
            ForEach(Array(vm.gridArray.enumerated()), id: \.offset) { _, columnsData in
                LazyVStack(spacing: verticalSpacing) {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
        .padding(padding)
    }
}

// MARK: - StaggeredGridVM

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Observable @MainActor
final class StaggeredGridVM<T: Identifiable & Equatable & Sendable> {
    // MARK: Lifecycle

    // MARK: - Initialization

    init(list: [T] = [], columns: Int = 1) {
        if !list.isEmpty, columns > 0 {
            self.gridArray = computeGridArray(list: list, columns: columns)
        }
    }

    // MARK: Internal

    var gridArray: [[T]] = []

    // MARK: - Methods

    func updateGridArray(list: [T], columns: Int) {
        let oldTask = updateTask
        // 异步计算
        // let threshold = 100 // 可调整的阈值
        let newTask = Task.detached(priority: .userInitiated) {
            _ = await oldTask?.value
            let newGridArray: [[T]] = self.computeGridArray(
                list: list, columns: columns
            )
            await MainActor.run {
                if !Task.isCancelled {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.gridArray = newGridArray
                    }
                }
            }
        }
        updateTask = newTask
    }

    /// 栏数变动时的重排：合并连续变动，且不与调用方的卡片尺寸脱节。
    ///
    /// 栏数不只决定分栏，**也决定每一栏的宽度**——调用方通常用同一个「清单列可用宽」同时算出
    /// 栏数与卡片边长（见 `AllIconSpecimenView_PerGame.gridMetrics(rowWidth:)`）。因此
    /// `gridArray.count` 与调用方的 `columns` 一旦不同步，网格就会以**旧栏数**摆放**新尺寸**的
    /// 固定尺寸卡片：卡片溢出自己的栏位、与邻栏重叠，内容高度也超出调用方给的
    /// `.frame(height: metrics.gridHeight)`。溢出的内容会让 `LazyVStack` 实体化远超可视范围的
    /// 元素，触发大量 HEIF 解码——实测 main thread 2075/2075 个采样全部卡在
    /// `RB::TextureCache::prepare_cgimage` → ImageIO 解码上，UI 因而看起来「卡死」。
    ///
    /// 逐次重排又都会带上 `withAnimation`，连续变动会把内容拆成好几段动画。所以这里的策略是
    /// **leading-edge ＋ trailing-edge 合并**：静默够久之后的第一次变动**立刻**重排（单一次
    /// 栏数变动不留任何尺寸／结构不一致的空窗）；只有紧接着又来变动（真的连续变动）才改成
    /// 等 `delay` 静默后做一次，把多段动画并成一段。
    ///
    /// 另外给连续变动设了上界：静默若一直不来（例如持续拖曳分割线，画布一直在变），最多延后
    /// `maxDeferral` 就先重排一次，免得旧栏数被无限期沿用。正常的一次折叠／旋转里连续变动总长
    /// 不超过这个上界，因此行为与纯「等静默」一致。
    func scheduleGridArrayUpdate(list: [T], columns: Int, delay: TimeInterval = 0.6) {
        let now = Date()
        // 与上一次栏数变动相隔够久 ⇒ 这是一次独立的变动，立刻重排。
        let isIsolatedChange = lastColumnsChangeAt.map { now.timeIntervalSince($0) >= delay } ?? true
        // 这一串连续变动已经拖太久了 ⇒ 不再等静默，先排一次并重新起算。
        let burstStartedAt = columnsBurstStartedAt ?? now
        let hasDeferredTooLong = now.timeIntervalSince(burstStartedAt) >= maxDeferral
        columnsUpdateTask?.cancel()
        columnsUpdateTask = nil
        lastColumnsChangeAt = now
        guard !isIsolatedChange, !hasDeferredTooLong else {
            columnsBurstStartedAt = nil
            updateGridArray(list: list, columns: columns)
            return
        }
        columnsBurstStartedAt = burstStartedAt
        columnsUpdateTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.columnsBurstStartedAt = nil
            self?.lastColumnsChangeAt = Date()
            self?.updateGridArray(list: list, columns: columns)
        }
    }

    // MARK: Private

    @ObservationIgnored private var updateTask: Task<Void, Never>?
    @ObservationIgnored private var columnsUpdateTask: Task<Void, Never>?
    @ObservationIgnored private var lastColumnsChangeAt: Date?

    /// 这一串连续变动是从何时开始的；静默迟迟不来时，用它给延后设上界。
    @ObservationIgnored private var columnsBurstStartedAt: Date?
    /// 连续变动的最大延后时长（对齐 `ScreenVM` settle window 的 `maxDelay`）。
    @ObservationIgnored private let maxDeferral: TimeInterval = 0.7

    // 同步计算方法，`nonisolated`：只读参数、不碰隔离状态，所以 `updateGridArray()` 的
    // `Task.detached` 能真的把这段分堆丢到背景跑（否则 `await` 会先跳回主执行绪再算）。
    nonisolated private func computeGridArray(list: [T], columns: Int) -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0
        for object in list {
            gridArray[currentIndex].append(object)
            currentIndex = currentIndex == (columns - 1) ? 0 : currentIndex + 1
        }
        return gridArray
    }
}

// MARK: - API Compatibility

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension StaggeredGrid {
    public init(
        columns: Int,
        showsIndicators: Bool = false,
        outerPadding: Bool = true,
        scroll: Bool = true,
        spacing: CGFloat = 10,
        renderedColumnCount: Binding<Int>? = nil,
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.init(
            columns: columns,
            scrollAxis: [],
            showsIndicators: showsIndicators,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            padding: outerPadding
                ? .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
                : .init(top: 0, leading: 0, bottom: 0, trailing: 0),
            alignment: .top,
            renderedColumnCount: renderedColumnCount,
            list: list,
            content: content
        )
    }
}

#endif
