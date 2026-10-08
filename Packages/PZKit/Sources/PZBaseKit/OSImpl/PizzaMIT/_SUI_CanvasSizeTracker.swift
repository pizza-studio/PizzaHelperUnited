// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

// MARK: - CanvasSizeTracker

@available(iOS 16.0, macCatalyst 16.0, *)
private struct CanvasSizeTracker: ViewModifier {
    // MARK: Lifecycle

    public init(
        handler: @escaping (CGSize) -> Void,
        debounceDelay: TimeInterval = 0.05,
        includingSafeArea regions: SafeAreaRegions = [],
        edges: Edge.Set = []
    ) {
        self.debounceDelay = debounceDelay
        self.handler = handler
        self.safeAreaRegions = regions
        self.safeAreaEdges = edges
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        content
            .background {
                readingLayout
            }
            .onAppear {
                // 确保 SizeState 的 debounceDelay 与当前参数保持一致。
                // 正常情况下 debounceDelay 不变，@State 会保留原有 SizeState；
                // 若 SwiftUI 因 view identity 变更而重建了 @State，这里至少保证
                // 新 SizeState 拿到正确的 debounceDelay。
                if sizeState.debounceDelay != debounceDelay {
                    sizeState = SizeState(debounceDelay: debounceDelay)
                }
            }
    }

    // MARK: Private

    @State private var sizeState: SizeState = .init(debounceDelay: 0.05)

    private let handler: (CGSize) -> Void
    private let debounceDelay: TimeInterval
    private let safeAreaRegions: SafeAreaRegions
    private let safeAreaEdges: Edge.Set

    /// 量测用的 background。
    ///
    /// 预设（`regions` 与 `edges` 皆为空）量到的是**扣除安全区**之后的「内容」尺寸。
    /// 传入 `regions` 与 `edges` 时，被指名的那几类安全区（也就是出血边界所占的区域）
    /// 会一并计入量测。
    ///
    /// 之所以要有这层区分：iPhone Duo 展开时，系统会在尾端留一条 vertical bar 的
    /// 安全区（实测 84pt；下缘另有 34pt），它是以 horizontal safe area inset 的形式
    /// 抵达的。若把所有安全区一律排除，`ScreenVM.windowSizeObserved` 这类维护「视窗
    /// 尺寸」的量测就会低估一整个 bar 的宽度，导致依赖它的背景出血范围
    /// （例如 `AvatarStatCollectionTabView`）覆盖不到该区域。
    /// - Important: 实现上**刻意不**用 `View.ignoresSafeArea(_:edges:)`。
    ///   一旦这类自订 Layout 被 `_SafeAreaRegionsIgnoringLayout` 包住，
    ///   `placeSubviews(in:proposal:subviews:cache:)` 在安全区反覆变动时（例如
    ///   `UINavigationController` 的互动式 pop 转场：UIKit 会反覆重算
    ///   `UIScrollView.safeAreaInsets`）会无限自我递回，直到把主执行绪的 stack
    ///   用尽（2026-10-08 实测堆到 20 万余层后 `EXC_BAD_ACCESS`）。
    ///   这里改用 `GeometryReader` 读取容器安全区、直接加回量测值：效果相同，
    ///   但量测过程不会参与版面递回。
    /// - Note: `GeometryProxy.safeAreaInsets` 在键盘升起时也会包含键盘的 inset，
    ///   因此加回之后量到的值不会随键盘缩小；`regions` 因此只认 `.container`。
    @ViewBuilder private var readingLayout: some View {
        GeometryReader { [weak sizeState] geometryProxy in
            let inflations = Self.inflations(
                from: geometryProxy.safeAreaInsets,
                regions: safeAreaRegions,
                edges: safeAreaEdges
            )
            SizeReadingLayout(onChange: { size in
                let measured = CGSize(
                    width: size.width + inflations.leading + inflations.trailing,
                    height: size.height + inflations.top + inflations.bottom
                )
                Task { @MainActor in
                    // 这个 `yield` 是必要的：`Task { @MainActor in }` 在同一个 main actor
                    // （也就是 `placeSubviews(in:proposal:subviews:cache:)` 所在的执行绪）
                    // 上建立时，工作有可能在第一个 suspend point 之前就同步跑起来。那样一来
                    // `sizeState.update(...)` 会在 SwiftUI 的 layout pass 之内发生，可能立刻
                    // 触发下一轮 layout、形成同步递回。先让出一次，保证这段工作绝不在
                    // layout pass 内执行。
                    await Task.yield()
                    guard let sizeState else { return }
                    sizeState.update(width: measured.width, height: measured.height)
                    sizeState.debounce(handler: handler)
                }
            }) {
                Color.clear
            }
        }
    }

    /// 计算要加回量测值的出血边界宽度。
    ///
    /// `edges` 是 `Edge.Set`，所以 `.all` / `.horizontal` / `.vertical` 会自然涵盖其成员边。
    private static func inflations(
        from insets: EdgeInsets,
        regions: SafeAreaRegions,
        edges: Edge.Set
    )
        -> EdgeInsets {
        guard regions.contains(.container), !edges.isEmpty else { return EdgeInsets() }
        var output = EdgeInsets()
        if edges.contains(.top) { output.top = insets.top }
        if edges.contains(.leading) { output.leading = insets.leading }
        if edges.contains(.bottom) { output.bottom = insets.bottom }
        if edges.contains(.trailing) { output.trailing = insets.trailing }
        return output
    }
}

// MARK: - SizeReadingLayout

/// 一个纯粹用于读取尺寸的 Layout，不干扰子视图的默认布局行为。
@available(iOS 16.0, macCatalyst 16.0, *)
private struct SizeReadingLayout: Layout {
    // MARK: Lifecycle

    init(onChange: @Sendable @escaping (CGSize) -> Void) {
        self.onChange = .init(onChange)
    }

    // MARK: Internal

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // 直接返回子视图（Color.clear）在当前建议下的大小
        // Color.clear 通常会填充建议的尺寸
        subviews.first?.sizeThatFits(proposal) ?? .zero
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        // 放置子视图
        subviews.first?.place(at: bounds.origin, proposal: proposal)

        // 报告尺寸
        onChange.withLock { $0(bounds.size) }
    }

    // MARK: Private

    private let onChange: NSMutex<(CGSize) -> Void>
}

// MARK: - SizeState

/// This doesn't need to be @Observable.
@MainActor
private class SizeState {
    // MARK: Lifecycle

    init(debounceDelay: TimeInterval) {
        self.debounceDelay = debounceDelay
    }

    // MARK: Internal

    private(set) var debounceDelay: TimeInterval
    var size: CGSize = .zero

    func update(width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width, width.isFinite, width >= 0, size.width != width {
            size.width = width
            isDirty = true
        }
        if let height = height, height.isFinite, height >= 0, size.height != height {
            size.height = height
            isDirty = true
        }
    }

    func debounce(handler: @escaping (CGSize) -> Void) {
        guard size.width > 0, size.height > 0 else { return }
        // `SizeReadingLayout.placeSubviews` 每一次排版都会回报一次，而同尺寸的重复回报占绝大多数
        // （实测 22 秒静置期间，除了最初两秒之外每个 Layout pass 都回报一次相同尺寸）。
        // 尺寸没变就不必重新起算静默窗，更不必为了重新起算而配置一个 `Task`：这里直接用
        // `isDirty` 挡掉——尺寸真的变了才会重新武装。
        guard isDirty else { return }
        isDirty = false
        task?.cancel()
        let delay = debounceDelay
        task = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            try Task.checkCancellation()
            guard let self else { return }
            handler(size)
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
    /// 自上一次武装之后量测值是否真的变过。用于挡掉同尺寸的重复回报。
    private var isDirty: Bool = false
}

@available(iOS 16.0, macCatalyst 16.0, *)
extension View {
    /// 量测 `self` 的画布尺寸，并在尺寸稳定后（去抖）回报。
    ///
    /// - Parameters:
    ///   - debounceDelay: 尺寸稳定后延迟多久才回报。
    ///   - regions: 要一并计入量测的安全区类型；预设 `[]`＝只量内容尺寸。
    ///     维护「视窗尺寸」这类含出血边界的量测请传 `.container`；`.keyboard`
    ///     刻意留给呼叫方自行决定，以免键盘弹出时把视窗尺寸误判成较小值。
    ///   - edges: 要一并计入量测的边；预设 `[]`。传 `.all` 会连 iPhone Duo 展开时
    ///     尾端 vertical bar 所占的那一条（实测 84pt）一同计入。
    ///   - handler: 去抖后的尺寸回报。
    @ViewBuilder
    public func trackCanvasSize(
        debounceDelay: TimeInterval = 0.05,
        includingSafeArea regions: SafeAreaRegions = [],
        edges: Edge.Set = [],
        handler: @escaping (CGSize) -> Void
    )
        -> some View {
        modifier(
            CanvasSizeTracker(
                handler: handler,
                debounceDelay: debounceDelay,
                includingSafeArea: regions,
                edges: edges
            )
        )
    }
}

// MARK: - ListRowContentWidthReporter

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension View {
    /// 就地量测 `Form` 列内容**未被上限裁剪**的可用宽度，并回报给 `ScreenVM`。
    ///
    /// 直接对 `.frame(maxWidth:)` 量测只会拿到被上限裁剪后的宽度：列内容由窄变宽时
    /// （设备旋转、Duo 开合状态改变）量到的宽度不会跟着变大，上限便锁死在旧值。本方法把
    /// `self` 与 `ListRowWidthMarker` 一起放进 `VStack` 后再量测该 `VStack`，贪心的
    /// marker 会让量到的宽度等于该列真正的提案宽度。
    ///
    /// 量测结果**不会**被本地立刻套用，而是先 stage 进 `ScreenVM`，由那唯一的「排版状态提交」
    /// 统一落定，再经由 `EnvironmentValues.listRowContentWidth` 回到各消费端：量测时机仍由
    /// 排版驱动，套用时机却与 `NavigationSplitView` 的可见性变化绑在同一次提交上。
    ///
    /// ```swift
    /// contents
    ///     .reportListRowContentWidth()
    /// ```
    ///
    /// - Parameters:
    ///   - column: 回报给哪一栏；预设读环境值 `listRowColumn`（`ContentView` 依栏位注入）。
    ///   - debounceDelay: 尺寸稳定后延迟多久才回报。
    @ViewBuilder
    public func reportListRowContentWidth(
        for column: ScreenVM.ListRowColumn? = nil,
        debounceDelay: TimeInterval = 0.05
    )
        -> some View {
        modifier(ListRowContentWidthReporter(column: column, debounceDelay: debounceDelay))
    }
}

// MARK: - ListRowContentWidthReporter

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
private struct ListRowContentWidthReporter: ViewModifier {
    // MARK: Internal

    let column: ScreenVM.ListRowColumn?
    let debounceDelay: TimeInterval

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            ListRowWidthMarker()
            content
        }
        // 量到的宽必须是「上级给的提案宽」，绝不能被溢出的内容撑大。
        //
        // 反例（实测发生过）：某个提案宽比真实可用宽还大时，固定尺寸的网格会溢出自己的栏位；
        // 溢出的内容把 `VStack` 的量测宽撑大，下一次提案又更大，形成正回授。旋转设备后它曾在
        // 30 秒内一路放大到整个 app 卡死（画面只剩互相重叠的卡片、系统时钟都不再走动）。
        .frame(maxWidth: .infinity, alignment: .leading)
        .trackCanvasSize(debounceDelay: debounceDelay) { newSize in
            ScreenVM.shared.reportListRowContentWidth(newSize.width, for: column ?? envColumn)
        }
    }

    // MARK: Private

    @Environment(\.listRowColumn) private var envColumn: ScreenVM.ListRowColumn
}

// MARK: - ListRowWidthMarker

/// 见 `View.reportListRowContentWidth(for:debounceDelay:)`。宽度贪心、高度为零，不产生视觉与排版占位。
public struct ListRowWidthMarker: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        Color.clear.frame(maxWidth: .infinity, maxHeight: 0)
    }
}
