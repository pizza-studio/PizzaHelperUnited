// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Defaults
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

#if compiler(<6.2)
extension Notification: @unchecked @retroactive Sendable {}
#endif

// MARK: - ScreenVM

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Observable
@MainActor
public final class ScreenVM {
    // MARK: Lifecycle

    public init() {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        // 启用设备方向通知
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        // 使用 UIWindowScene.interfaceOrientation 作为回退
        let orientationNow = Self.getInitialOrientation()
        self.orientation = orientationNow
        // 以下都是「已提交值」的种子：先放暂定值，第一次排版状态提交后由观测值取代。
        self.isHorizontallyCompact = Self.getInitialHorizontalSizeClass() == .compact
        self.actualSidebarWidthObserved = 0
        self.windowSizeObserved = Self.getKeyWindowSize()
        self.mainColumnSidebarPaddingOffset = 0
        // 先用上次启动时记下的铰链状态当暂定值：铰链 API 的首次回呼要等约 0.9 秒才到，
        // 不等它的话，首屏的 splitViewVisibility 会用未经反相的方向判定。
        let cachedHingeStatus = Defaults[.lastKnownHingeStatus].flatMap(HingeStatus.init(rawValue:))
        let cachedHingeAngleInDegrees = Defaults[.lastKnownHingeAngleInDegrees]
        self.hingeStatus = cachedHingeStatus
        self.hingeAngleInDegrees = cachedHingeAngleInDegrees
        // 初始化 splitViewVisibility（此处尚未完成全部属性初始化，只能走 static helper）
        // 铰链张开时改看视窗长宽比，不用系统回报的方向（实测 iPhone Duo 呈书本状展开时仍报 landscape）。
        self.splitViewVisibility = Self.shouldShowSidebar(
            reportedOrientation: orientationNow,
            isCompactWidth: Self.getInitialHorizontalSizeClass() == .compact,
            isHingeOpen: cachedHingeStatus != nil && (cachedHingeAngleInDegrees ?? 0) > 0,
            windowSize: Self.getKeyWindowSize(),
            screenSize: Self.getScreenSize()
        ) ? .all : .detailOnly
        let orientationRAW = orientation.rawValue
        let splitViewVisibilityRAW = String(describing: splitViewVisibility)
        let hingeRAW = "\(hingeStatus?.rawValue ?? "nil")@\(hingeAngleInDegrees.map { "\($0)" } ?? "nil")"
        PZLog.info(
            "初始方向: \(orientationRAW), splitViewVisibility: \(splitViewVisibilityRAW), 暂定铰链: \(hingeRAW)"
        )
        Task { @MainActor in
            for await notification in NotificationCenter.default.notifications(
                named: UIDevice.orientationDidChangeNotification
            ) {
                guard let deviceOrientation = (notification.object as? UIDevice)?.orientation else { continue }
                let newOrientation: Orientation? = {
                    if deviceOrientation.isPortrait { return .portrait }
                    if deviceOrientation.isLandscape { return .landscape }
                    return nil
                }()
                guard let newOrientation else { continue }
                // 不再自带去抖：只写 pending，记录与落定交给 `reportLayoutStateObservation()`
                // （见 `reportOrientation(_:)` 与 `recordPendingObservations()`）。
                self.reportOrientation(newOrientation)
                PZLog.info(
                    "方向更新: \(newOrientation.rawValue), windowSizeObserved: \(String(describing: self.windowSizeObserved))"
                )
            }
        }
        #else
        self.orientation = .landscape
        self.isHorizontallyCompact = false
        self.actualSidebarWidthObserved = 0
        self.windowSizeObserved = Self.getKeyWindowSize()
        self.mainColumnSidebarPaddingOffset = 0
        self.splitViewVisibility = .all // macOS 默认显示侧边栏
        #endif
        updateHash4Tracking() // 初始化 hashForTracking
        registerObservation()
        #if os(iOS) && !targetEnvironment(macCatalyst)
        // 尽量在首屏判定之前就拿到铰链状态：SwiftUI 修饰器要等视图挂载才回呼，实测晚了约 0.9 秒。
        startEarlyHingeTracking()
        #endif
    }

    deinit {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        Task { @MainActor in
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        #endif
    }

    // MARK: Public

    public enum Orientation: String, Hashable, Equatable, Identifiable {
        case portrait
        case landscape

        // MARK: Public

        public var id: String { rawValue }
    }

    /// 折叠装置的铰链状态（例如 iPhone Duo）。
    /// `nil` 表示拿不到铰链资讯：非折叠机、所在层级不提供，
    /// 或者这个建置目标根本不参与此机制（macCatalyst / AppKit）。
    public enum HingeStatus: String, Hashable, Equatable, Sendable {
        case closed
        case partiallyOpen
        case fullyOpen
        case unknown
    }

    /// 清单列所属的栏位。供 `View.reportListRowContentWidth(for:)` 决定量到的宽度该回报给哪一栏。
    public enum ListRowColumn: Sendable, Hashable {
        case sidebar
        case mainColumn
    }

    public static let shared = ScreenVM()

    /// 当前方向。**已提交值**：方向通知只做 stage，落定于 `commitLayoutState()`。
    public private(set) var orientation: Orientation
    /// 折叠装置的铰链状态。**已提交值**，语义见 `HingeStatus`。
    public private(set) var hingeStatus: HingeStatus?
    /// 折叠装置铰链的开阖角度（度数）。`nil` 的含义与 `hingeStatus` 相同。
    /// **已提交值**：铰链在扳动时会高频回报，但消费端只会在一次提交里看到新的值。
    public private(set) var hingeAngleInDegrees: Double?
    public private(set) var isHorizontallyCompact: Bool
    public private(set) var actualSidebarWidthObserved: CGFloat
    /// App 视窗的尺寸（含 iPhone Duo 展开时尾端 vertical bar 所占的出血边界）。
    ///
    /// 初始值为 `getKeyWindowSize()` 的**暂定值**，它在启动阶段可能因 key window 尚未
    /// 就绪而失真；一旦 `ScreenVM.ViewTracker` 量到尺寸，就会以量测值为准。
    public private(set) var windowSizeObserved: CGSize
    public var splitViewVisibility: NavigationSplitViewVisibility

    /// Sidebar padding 偏移量。经由 CanvasSizeTracker 直接量取校准。
    /// 该值恒为非负数。**已提交值**。
    public private(set) var mainColumnSidebarPaddingOffset: CGFloat

    public private(set) var hashForTracking: Int = 0

    /// 视窗尺寸（**不含**出血边界）：由 `ContentView` 的 tracker 直接量取。
    /// 与 `windowSizeObserved`（含出血）成对存在，供需要「实际可用排版宽度」的场合使用。
    public private(set) var windowSizeObservedSansBleed: CGSize = .zero

    /// Main Column（detail 栏）尺寸（**不含**出血边界）：由 `ContentView` 的 tracker 直接量取。
    public private(set) var mainColumnSizeObservedSansBleed: CGSize = .zero

    /// Main Column（detail 栏）尺寸（**含**出血边界）：由 `ContentView` 的 tracker 直接量取。
    public private(set) var mainColumnSizeObservedWithBleed: CGSize = .zero

    /// 清单列（`Form` / `List` 的单行内容区）的**可用内容宽**：Sidebar 栏。
    ///
    /// 这是该栏位某一列的 `ListRowWidthMarker` 跑出的**原始实测值**（见
    /// `View.reportListRowContentWidth(for:)`），且只在「量测静下来之后」才更新一次：
    /// 每个新的量测都会把落定去抖器重新计时，所以一次旋转 / 铰链开合过程中那些中途的提案宽
    /// 一律不会发布出去，消费端（`StaggeredGrid` 等）的排版动画因此只会在最后触发一次。
    ///
    /// 之所以发布实测值而不是「画布宽 — 内缩量」的推算值：推算值在过程中会随画布一步步变动，
    /// 每变一步内容就重排一次动画；而实测值本身就是容器给的提案宽，与网格自身的宽度完全一致，
    /// 不会出现固定尺寸的 specimen 溢出栏位、互相重叠的问题。
    ///
    /// 为 0 表示尚未量到（首帧），消费端应退回自己的保守估值。
    public private(set) var sidebarRowContentWidth: CGFloat = 0

    /// 清单列的**可用内容宽**：Main Column（detail 栏）。语义同 `sidebarRowContentWidth`。
    public private(set) var mainColumnRowContentWidth: CGFloat = 0

    /// Main Column 的画布尺寸（**可排版区**：整窗扣掉安全区出血，必要时再扣掉侧栏）。
    ///
    /// 宽度依侧栏是否在场分成两种取法，但两者都得到**不含出血**的主栏宽：
    /// - `.all`：`windowSizeObserved`（含出血）− `actualSidebarWidthObserved` −
    ///   `mainColumnSidebarPaddingOffset`。这里必须用含出血的整窗宽，因为
    ///   `mainColumnSidebarPaddingOffset` 正是拿含出血的整窗宽校准出来的
    ///   （见 `recordSidebarPaddingOffset()`）：同源相减，出血才会被恰好抵消掉。
    /// - `.detailOnly`：主栏即整窗，没有侧栏与 offset 可扣，于是直接用整窗——但必须是
    ///   **不含出血**的整窗（封面萤幕实测：满版 466×678、可用 382×644，尾端竖条 84pt、
    ///   下缘 34pt）。上面 `.all` 那条路若推算出非正值，也退回同一个可用尺寸。
    ///
    /// 高度不吃侧栏，一律取不含出血的整窗高：下缘那 34pt 是系统手势区，不属于可排版区。
    ///
    /// 三者都是**已提交值**，因此它只在一次排版状态提交之后才变动一次。
    public var mainColumnCanvasSizeObserved: CGSize {
        let usableSize = usableWindowSize
        guard splitViewVisibility != .detailOnly else { return usableSize }
        let mainColumnWidth = windowSizeObserved.width - actualSidebarWidthObserved
            - mainColumnSidebarPaddingOffset
        guard mainColumnWidth > 0 else { return usableSize }
        return CGSize(width: mainColumnWidth, height: usableSize.height)
    }

    // iPhone Portrait Display mode or similar canvas size.
    // 440 是 iPhone 16 Pro Max 的荧幕画布尺寸。
    public var isPhonePortraitSituation: Bool {
        isHorizontallyCompact && usableWindowSize.width <= 440
    }

    // iPhone SE3 ZOOMED mode.
    public var isExtremeCompact: Bool {
        mainColumnCanvasSizeObserved.width < 375
    }

    public var isSidebarVisible: Bool {
        var isSidebarVisibleNow = splitViewVisibility == .all
        isSidebarVisibleNow = isSidebarVisibleNow && !isHorizontallyCompact
        return isSidebarVisibleNow
    }

    /// 铰链是否处于张开状态：有铰链资讯、且开阖角度大于 0。
    public var isHingeOpen: Bool {
        Self.isHingeOpen(status: hingeStatus, angleInDegrees: hingeAngleInDegrees)
    }

    /// App 的视窗是否占满整个萤幕，而不是被系统塞在左页、右页或上下其中一页。
    ///
    /// 实测 iPhone Duo 满版时视窗约为萤幕的 0.88～0.95（差额来自状态栏与边缘安全区）；
    /// 被塞进单页时其中一轴只剩约 0.5，故门槛取 0.75。
    public var isAppOccupyingWholeScreen: Bool {
        Self.isAppOccupyingWholeScreen(windowSize: windowSizeObserved, screenSize: Self.getScreenSize())
    }

    /// `isHingeOpen` 的纯函式版本；供 staged 观测值（尚未提交、不能碰 self 属性时）判定用。
    public static func isHingeOpen(status: HingeStatus?, angleInDegrees: Double?) -> Bool {
        guard status != nil else { return false }
        return (angleInDegrees ?? 0) > 0
    }

    /// `isAppOccupyingWholeScreen` 的纯函式版本；供 init（尚不能碰 self 方法时）与实例属性共用。
    public static func isAppOccupyingWholeScreen(windowSize: CGSize, screenSize: CGSize) -> Bool {
        guard screenSize.width > 1, screenSize.height > 1 else { return true }
        return windowSize.width >= screenSize.width * 0.75
            && windowSize.height >= screenSize.height * 0.75
    }

    /// 边栏是否该显示。供 `ViewTracker` 与首屏判定共用，规则只有一份。
    ///
    /// - 折叠装置铰链张开时：系统回报的装置方向不可信（实测 iPhone Duo 呈书本状展开时仍报 landscape），
    ///   改看视窗本身的长宽比：比高宽＝两页左右并排，才显示边栏；被系统塞进单页时一律不显示。
    /// - 铰链未张开时：沿用既有规则（横向下且非 compact 宽度）。
    public static func shouldShowSidebar(
        reportedOrientation: Orientation,
        isCompactWidth: Bool,
        isHingeOpen: Bool,
        windowSize: CGSize,
        screenSize: CGSize
    )
        -> Bool {
        if isHingeOpen {
            guard isAppOccupyingWholeScreen(windowSize: windowSize, screenSize: screenSize) else { return false }
            return windowSize.width > windowSize.height
        }
        return reportedOrientation == .landscape && !isCompactWidth
    }

    /// `shouldShowSidebar` 的实例便捷版本。
    public func shouldShowSidebar(isCompactWidth: Bool) -> Bool {
        Self.shouldShowSidebar(
            reportedOrientation: orientation,
            isCompactWidth: isCompactWidth,
            isHingeOpen: isHingeOpen,
            windowSize: windowSizeObserved,
            screenSize: Self.getScreenSize()
        )
    }

    /// 回报一次「影响整体排版状态」的观测。
    ///
    /// 视窗尺寸、方向、铰链、各栏宽度原本各自带不同的去抖机制与延迟，于是一次旋转 /
    /// 铰链开合会让 `splitViewVisibility` 与各栏宽度基准先后变动好几次，内容端
    /// （specimen 这类 `StaggeredGrid`）便跟着重排好几次、与 `NavigationSplitView`
    /// 的自适应动画彼此撞车。
    ///
    /// 现在这些观测一律只写进 pending 槽，并 poke 唯一的静默窗：
    /// **记录本身也是去抖的**——等原始观测流停下来，才把最后一代写进 staged 快照并提交一次
    /// （见 `recordPendingObservations()`）。这样中间世代既不会污染派生值（offset），
    /// 也不会被当成真值提交给消费端。
    public func reportLayoutStateObservation() {
        // 落定条件：从「第一笔观测」算起，要嘛已经静默满 `settleDelay`，要嘛已经等满 `maxDelay`。
        // 上限存在的理由：纯 trailing-edge 在观测**持续到来**时可以永远不触发——一次旋转 /
        // 铰链开合期间系统会连续给出一世代又一世代的中途值，若每次都被重新计时，就一次都提交不了。
        // 上限保证「输入不停也终究会落定一次」。
        let now = Date()
        observationRecordStartedAt = observationRecordStartedAt ?? now
        lastObservationAt = now
        // 闸门：同一时间只允许一个计时任务。少了它，持续输入下每一笔观测都会另起一个任务，
        // 每个任务各自提交一次，于是「一次旋转」被拆成几十次提交。
        guard observationRecordTask == nil else { return }
        observationRecordTask = Task { @MainActor [weak self] in
            let settleDelay = self?.layoutSettleDelay ?? 0.7
            let maxDelay = 3.0
            let startedAt = self?.observationRecordStartedAt
            do {
                while let self {
                    // 每一圈都先检查取消：`Task.sleep` 一旦被取消就**立刻返回**
                    // （而不是抛错），若不在圈首显式检查，这个回圈会变成不睡的空转。
                    try Task.checkCancellation()
                    if let lastObservationAt = lastObservationAt,
                       Date().timeIntervalSince(lastObservationAt) >= settleDelay {
                        lastObservationLooksSettled = true
                        break // 静默窗内没有新观测进来：真的静下来了。
                    }
                    if let startedAt, Date().timeIntervalSince(startedAt) >= maxDelay {
                        lastObservationLooksSettled = false
                        break // 观测持续不断：到上限就强制落定一次。
                    }
                    try await Task.sleep(for: .seconds(settleDelay))
                }
                try Task.checkCancellation()
                guard let self else { return }
                observationRecordStartedAt = nil
                lastObservationAt = nil
                await recordPendingObservations()
            } catch {
                // 被 `recordPendingObservationsImmediately()` 或除役取消。
            }
            // 提交确实结束之后才解除闸门：否则下一笔观测会在提交还在跑时就另起一个任务。
            self?.observationRecordTask = nil
        }
    }

    /// 回报一次铰链观测结果。
    ///
    /// 与其它排版观测一样只写 pending；但**开阖状态一翻就立刻记录并提交一次**：折叠过程中角度会持续
    /// 高频变化，若一路走 trailing-edge 去抖，可见性判定要等手停下来才落定（实测很慢）。
    /// 开阖状态翻转过后的角度微调仍走去抖，不会再多触发提交。
    public func reportHingeObservation(status: HingeStatus?, angleInDegrees: Double?) {
        let wasOpen = Self.isHingeOpen(status: hingeStatus, angleInDegrees: hingeAngleInDegrees)
        applyHingeObservation(status: status, angleInDegrees: angleInDegrees)
        let isOpenNow = Self.isHingeOpen(
            status: pendingHinge?.status ?? stagedHinge?.status ?? hingeStatus,
            angleInDegrees: pendingHinge?.angleInDegrees ?? stagedHinge?.angleInDegrees ?? hingeAngleInDegrees
        )
        guard wasOpen != isOpenNow else { return }
        // 立刻记录，不必再等静默窗：折合状态翻转需要即时生效。
        recordPendingObservationsImmediately()
    }

    /// 回报一次方向观测。
    public func reportOrientation(_ newOrientation: Orientation) {
        guard (pendingOrientation ?? stagedOrientation ?? orientation) != newOrientation else { return }
        pendingOrientation = newOrientation
        // A（转向 / 铰链翻转）就是一次排版过渡的起点。见 `layoutTransitionArmedAt`。
        layoutTransitionArmedAt = Date()
        reportLayoutStateObservation()
    }

    /// 回报一次横向 size class 观测。
    public func reportHorizontalSizeClass(isCompact: Bool) {
        guard (pendingIsHorizontallyCompact ?? stagedIsHorizontallyCompact ?? isHorizontallyCompact) != isCompact
        else { return }
        pendingIsHorizontallyCompact = isCompact
        layoutTransitionArmedAt = Date()
        reportLayoutStateObservation()
    }

    /// 回报一次「App 视窗尺寸（含出血）」观测：由 `ScreenVM.ViewTracker` 的量测器调用。
    public func reportWindowSize(_ trackedSize: CGSize) {
        guard trackedSize.width > 0, trackedSize.height > 0 else { return }
        var newSize = trackedSize
        newSize.width.round(.up)
        newSize.height.round(.up)
        guard (pendingWindowSize ?? stagedWindowSize ?? windowSizeObserved) != newSize else { return }
        pendingWindowSize = newSize
        reportLayoutStateObservation()
    }

    /// 回报一次「该栏清单列可用内容宽」的就地量测结果。
    ///
    /// 收到的就是消费端最终要用的宽度（容器给的提案宽），但**不会立刻发布**：与其它几何观测一样
    /// 只写 pending，由 `reportLayoutStateObservation()` 那唯一的静默窗一次落定。
    ///
    /// - Important: 这里**刻意不再**带自己的去抖器。曾经它由一个独立的 0.7s 去抖器发布，结果是
    ///   它可以跟「栏位画布」分属不同排版世代：`isStaleRowWidthMeasurement` 与
    ///   `invalidateRowContentWidthsExceedingCanvas()` 都只在提交时机检查，而两者来自不同的时序，
    ///   于是「已发布的宽 > 当下画布」这种状态会存在（实测 rowMain=807 与 canvas=372 并存）。
    ///   同一批提交既保证世代一致，也让消抖只剩一处。
    /// 见 `View.reportListRowContentWidth(for:debounceDelay:)`。
    public func reportListRowContentWidth(_ width: CGFloat, for column: ListRowColumn) {
        reportListRowContentWidth(width, for: column, pokingTheSettleWindow: true)
    }

    public func handleTrackedSidebarCanvasSize(_ trackedSize: CGSize) {
        guard trackedSize.width > 0 else { return }
        let newValue = trackedSize.width.rounded(.up)
        guard (pendingSidebarWidth ?? stagedSidebarWidth ?? actualSidebarWidthObserved) != newValue else { return }
        pendingSidebarWidth = newValue
        retryRejectedRowContentWidths()
        reportLayoutStateObservation()
    }

    /// 视窗尺寸的量测回报（`includingBleed == false` 的那一份）。
    ///
    /// 含出血的那一份由 `ScreenVM.ViewTracker` 负责（同样挂在 `ContentView` 上），
    /// 写进 `windowSizeObserved`；此处只补「不含出血」的观测。
    public func handleTrackedWindowSize(_ trackedSize: CGSize, includingBleed: Bool) {
        guard !includingBleed else { return }
        guard trackedSize.width > 0, trackedSize.height > 0 else { return }
        var newSize = trackedSize
        newSize.width.round(.up)
        newSize.height.round(.up)
        guard (pendingWindowSizeSansBleed ?? stagedWindowSizeSansBleed ?? windowSizeObservedSansBleed) != newSize
        else { return }
        pendingWindowSizeSansBleed = newSize
        reportLayoutStateObservation()
    }

    /// Main Column（detail 栏）尺寸的量测回报：含出血与不含出血各写一份。
    public func handleTrackedMainColumnSize(_ trackedSize: CGSize, includingBleed: Bool) {
        guard trackedSize.width > 0, trackedSize.height > 0 else { return }
        var newSize = trackedSize
        newSize.width.round(.up)
        newSize.height.round(.up)
        if includingBleed {
            guard (pendingMainColumnWithBleed ?? stagedMainColumnWithBleed ?? mainColumnSizeObservedWithBleed) !=
                newSize
            else { return }
            pendingMainColumnWithBleed = newSize
        } else {
            // offset 不在量测当下推算：那时窗口 / 侧栏宽可能还停在上一世代。改由
            // `recordPendingObservations()` 从同一批已记录的观测推算，因此这里值没变就不必 poke
            // （窗口 / 侧栏若有变动，各自会 poke；无谓地重启静默窗只会把提交一直往后推）。
            guard (pendingMainColumnSansBleed ?? stagedMainColumnSansBleed ?? mainColumnSizeObservedSansBleed)
                != newSize else { return }
            pendingMainColumnSansBleed = newSize
            // 画布刚变了：把先前被误判为残量的内容宽量测重投一次（铰链开合主要靠这一步）。
            retryRejectedRowContentWidths()
        }
        reportLayoutStateObservation()
    }

    // MARK: Private

    private struct HingeObservation {
        var status: HingeStatus?
        var angleInDegrees: Double?
    }

    /// 消费端当下可见的几何快照。
    ///
    /// 用来回答「这次提交到底改变了什么」。快照而不是逐槽标记：判据一旦写成「有没有哪一笔 staged 与已落定值
    /// 不同」，日后新增一个槽却忘了加标记，就会让一次该有的提交被略过——而这是最难查的一类错。
    private struct CommittedGeometry: Equatable {
        var orientation: Orientation
        var hingeStatus: HingeStatus?
        var hingeAngleInDegrees: Double?
        var isHorizontallyCompact: Bool
        var windowSizeObserved: CGSize
        var windowSizeObservedSansBleed: CGSize
        var actualSidebarWidthObserved: CGFloat
        var mainColumnSizeObservedSansBleed: CGSize
        var mainColumnSizeObservedWithBleed: CGSize
        var mainColumnSidebarPaddingOffset: CGFloat
    }

    /// 刚收到的**原始**排版观测值（pending）。
    ///
    /// 旋转 / 铰链 / 视窗与栏位量测在系统动画与栏位动画期间会连续给出好几代中途值（实测相隔
    /// 0.25–0.7s，甚至一秒以上）。这些原始值只写在这里；`reportLayoutStateObservation()` 等它们停下来
    /// 之后才「记录」进 staged 快照（`recordPendingObservations()`），中间世代于是既不会污染派生值
    /// （例如 sidebar padding offset 由窗口 − 侧栏 − 主栏宽推算，混用世代会算出荒谬值），
    /// 也不会被当成真值提交给消费端。
    private var pendingOrientation: Orientation?
    private var pendingHinge: HingeObservation?
    private var pendingIsHorizontallyCompact: Bool?
    private var pendingWindowSize: CGSize?
    private var pendingWindowSizeSansBleed: CGSize?
    private var pendingSidebarWidth: CGFloat?
    private var pendingMainColumnSansBleed: CGSize?
    private var pendingMainColumnWithBleed: CGSize?
    private var pendingSidebarRowContentWidth: CGFloat?
    private var pendingMainColumnRowContentWidth: CGFloat?

    /// 已记录、待提交的排版观测值（staged）。只由 `recordPendingObservations()` 写入，
    /// 再由 `commitLayoutState()` 一次性落定给消费端。
    ///
    /// 视窗尺寸、方向、铰链、各栏宽度与「清单列可用内容宽」原本各自带不同的去抖机制与延迟，
    /// 于是一次旋转 / 铰链开合会让消费端看到的状态先后变动好几次、内容跟着重排好几次。
    /// 现在所有观测都只在同一批记录里写进来，再由 `commitLayoutState()` 一次提交。
    private var stagedOrientation: Orientation?
    private var stagedHinge: HingeObservation?
    private var stagedIsHorizontallyCompact: Bool?
    private var stagedWindowSize: CGSize?
    private var stagedWindowSizeSansBleed: CGSize?
    private var stagedSidebarWidth: CGFloat?
    private var stagedMainColumnSansBleed: CGSize?
    private var stagedMainColumnWithBleed: CGSize?
    private var stagedSidebarPaddingOffset: CGFloat?
    private var stagedSidebarRowContentWidth: CGFloat?
    private var stagedMainColumnRowContentWidth: CGFloat?

    /// 最近一次就地量到的原始内容宽（去重用；提交后仍保留，staged 槽则会被清空）。
    private var lastReportedSidebarRowContentWidth: CGFloat?
    private var lastReportedMainColumnRowContentWidth: CGFloat?

    /// 被判定为「上一世代残量」而丢弃的量测，留着等栏位画布更新后重投。
    ///
    /// 必须有它们：`reportListRowContentWidth()` 只在**量到的宽度确实变化**时才会被呼叫
    /// （`SizeState` 以 `isDirty` 去重），所以一笔被丢掉的量测不会被自动重试。而栏位画布
    /// 与内容宽是同一轮排版里、由不同层级的追踪器分别回报的，两者到达顺序不保证：内容宽的
    /// 量测可能先到、被拿**还没更新的旧画布**判成残量而丢掉，随后画布才变大，但那一代
    /// 正确的宽度再也不会有人重报——消费者的每行容量就永久停在旧值上。
    /// 铰链的「close ↔ open」「halfOpen ↔ fullyOpen」正是这种情形：主机尺寸变了、内容宽却一直不更新。
    @ObservationIgnored private var rejectedSidebarRowContentWidth: CGFloat?
    @ObservationIgnored private var rejectedMainColumnRowContentWidth: CGFloat?

    /// 「原始观测」的记录静默窗：**记录本身也要去抖**。
    ///
    /// 一次旋转 / 铰链开合期间，pending 槽会被同一场排版的中间世代反复覆写。0.7s 是实测足以跨越
    /// 这些世代间隔的静默窗：等原始观测流停下来，才把最后一代记录进 staged 快照并提交一次，
    /// 可见性、各栏宽度基准与派生值于是在同一次提交里落定。
    ///
    /// - Important: 静默窗另有一个 3s 的上限（见 `reportLayoutStateObservation()`）。纯 trailing-edge
    ///   去抖在观测**持续到来**时可以永远不触发：实测 60Hz 合成过渡期间 300 次/秒的 poke 换到
    ///   `commits == 0`，也就是一次都不提交、画面停在旧几何上（使用者所谓「过了十几秒还是这样」）。
    ///   有上限才能保证「input 不停也终究会落定一次」。
    private var observationRecordTask: Task<Void, Never>?
    private var observationRecordStartedAt: Date?
    private var lastObservationAt: Date?
    /// 手上这份「清单列内容宽」是否是在**旧边栏可见性**下量到的过渡世代；是的话先不发布，
    /// 等下一个世代（边栏动画结束、追踪器重新回报之后）再落定。见 `commitLayoutState()`。
    private var deferredRowContentWidth: Bool = false
    /// 排版过渡的起点：最近一次「转向 / 横竖 size class 变化 / 铰链开阖翻转」的时刻。
    ///
    /// 边栏可见性（B）常常比几何（C1）晚几拍才到——`shouldShowSidebar()` 要等 `orientation`、
    /// `isHorizontallyCompact`、`hingeStatus` 都齐了才会给出新答案，而这些观测不是同一刻送达的。
    /// 若只在「这次提交刚好翻转可见性」时才按住内容宽，早几拍的那次提交就会把过渡世代发出去，
    /// 消费端于是先重排一次（D1），B/C2 落定后再重排一次（D2）——正是使用者描述的时序。
    /// 因此从 A 起就按住，等过了 `layoutSettleDelay` 才允许发布。
    private var layoutTransitionArmedAt: Date?
    /// 落定所需的静默时长。`reportLayoutStateObservation()` 的计时条件与
    /// `commitLayoutState()` 的「过渡是否已过」判断共用这一个值。
    private let layoutSettleDelay: TimeInterval = 0.7
    /// 上一轮静默窗是「真的静下来」结束的，还是被 `maxDelay` 上限强制结束的。
    ///
    /// 这是「内容宽能不能发布」的唯一可信判据。观测流没停下来时（`maxDelay` 强制提交、
    /// 或铰链翻转的立即提交），当下这份内容宽是在几何还在动的世代里量到的过渡态；发布出去
    /// 就是使用者看到的 D1。只有静默窗自然到期的那次提交，才保证几何已经静止了整整一个
    /// `layoutSettleDelay`。
    private var lastObservationLooksSettled: Bool = false
    /// 按住内容宽期间排定的一次补提交，见 `scheduleRowContentWidthReleaseIfNeeded()`。
    private var rowContentWidthReleaseTask: Task<Void, Never>?

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// 启动阶段就挂在 key window 上的铰链观察器；见 `startEarlyHingeTracking()`。
    @ObservationIgnored private var hingeInteraction: (any UIInteraction)?
    @ObservationIgnored private var hingeTrackingObserver: (any NSObjectProtocol)?
    #endif

    /// 不含出血边界的整窗尺寸（逐轴回退：该轴尚未量到就退回满版）。
    ///
    /// `windowSizeObserved` 含安全区出血：iPhone Duo 的尾端竖条恒占 84pt（下缘另有 34pt），
    /// 而这两处都并非可用排版区域。凡是「可用尺寸」语义的判定都必须用它，目前有两处：
    /// - `isPhonePortraitSituation`：440 这道门槛是按可用画布宽校准的，拿满版宽比对会把
    ///   封面萤幕（实测满版 466×678、可用 382×644）这种可用宽本来就在门槛内的情境
    ///   误判成宽萤幕，root page switcher 于是从底部 tab bar 被换成顶端 Picker。
    /// - `mainColumnCanvasSizeObserved`：`.detailOnly` 时主栏即整窗；高度一律取它。
    ///
    /// 量测尚未回报时（`windowSizeObservedSansBleed == .zero`）逐轴退回满版尺寸。
    private var usableWindowSize: CGSize {
        let sansBleed = windowSizeObservedSansBleed
        return CGSize(
            width: sansBleed.width > 0 ? sansBleed.width : windowSizeObserved.width,
            height: sansBleed.height > 0 ? sansBleed.height : windowSizeObserved.height
        )
    }

    /// 主栏内容宽的残量判定与作废共用的「主栏画布」。
    ///
    /// - Important: 必须把**尚未落定**的窗口 / 侧栏观测一并算进来，而不是只读已提交值。
    ///
    ///   侧栏 / 整窗的量测总是**先于**主栏内容重排抵达：铰链摊平那一刻，侧栏由 456 变 320，
    ///   页面随即量到 485 并回报，而 `mainColumnCanvasSizeObserved` 要等 0.7 秒后的提交才会
    ///   由 372 变成 508。若这里只读已提交值，485 会被旧世代的 372 判成残量丢弃；侧栏回报时
    ///   触发的那次重投（`retryRejectedRowContentWidths()`）会读同一个旧值再丢一次，于是
    ///   「每行格数」永远不更新——实测连续六笔 `485.0 > canvas 372.0` 全部被弃。
    ///
    ///   画布偏宽只会让判定变宽松（接受一笔将被证实的量测），偏窄才会误杀，因此这里一律取
    ///   「三个世代里最宽」的一版。
    ///
    ///   - Important: 「pending 优先」并不足以保证偏宽：侧栏自身也在动画，pending 的侧栏宽可能比已落定值
    ///     **更宽**（实测由 400 收到 251 的过程中出现过 533），算出的画布 295 会把一笔本来装得下的 336
    ///     判成残量丢掉，随后 `retryRejectedRowContentWidths()` 又把它重投一次——每一笔误杀都换成一次
    ///     多余的提交与 7–8 行诊断。因此这里改为：窗口宽取**最宽**、侧栏宽取**最窄**。
    ///
    ///   - Note: 放到这么宽是安全的，因为「发出去的值必须装得进当下这块画布」由
    ///     `clampPublishedRowContentWidthsToCanvas()` 在每次提交末尾兜底；这个判据只负责不误杀。
    private var mainColumnRowWidthCanvas: CGFloat {
        guard splitViewVisibility != .detailOnly else {
            return max(windowSizeObserved.width, pendingWindowSize?.width ?? 0, stagedWindowSize?.width ?? 0)
        }
        let windowWidth = max(
            windowSizeObserved.width,
            pendingWindowSize?.width ?? 0,
            stagedWindowSize?.width ?? 0
        )
        let sidebarWidth = [pendingSidebarWidth, stagedSidebarWidth, actualSidebarWidthObserved]
            .compactMap { $0 }
            .min() ?? actualSidebarWidthObserved
        let derived = windowWidth - sidebarWidth - mainColumnSidebarPaddingOffset
        return derived > 0 ? derived : windowWidth
    }

    private var committedGeometry: CommittedGeometry {
        CommittedGeometry(
            orientation: orientation,
            hingeStatus: hingeStatus,
            hingeAngleInDegrees: hingeAngleInDegrees,
            isHorizontallyCompact: isHorizontallyCompact,
            windowSizeObserved: windowSizeObserved,
            windowSizeObservedSansBleed: windowSizeObservedSansBleed,
            actualSidebarWidthObserved: actualSidebarWidthObserved,
            mainColumnSizeObservedSansBleed: mainColumnSizeObservedSansBleed,
            mainColumnSizeObservedWithBleed: mainColumnSizeObservedWithBleed,
            mainColumnSidebarPaddingOffset: mainColumnSidebarPaddingOffset
        )
    }

    // MARK: Static Helpers

    private static func getInitialOrientation() -> Orientation {
        guard OS.type != .macOS else { return .landscape }
        #if os(iOS) && !targetEnvironment(macCatalyst)
        // 优先使用 UIWindowScene.interfaceOrientation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation.screenVMOrientation
        } else {
            // 回退到 UIDevice.current.orientation
            let deviceOrientation = UIDevice.current.orientation
            guard deviceOrientation.isValidInterfaceOrientation else { return .portrait }
            return switch deviceOrientation {
            case .landscapeLeft, .landscapeRight: .landscape
            default: .portrait
            }
        }
        #else
        return .landscape
        #endif
    }

    private static func getInitialHorizontalSizeClass() -> UserInterfaceSizeClass? {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene
        else { return nil }
        switch windowScene.traitCollection.horizontalSizeClass {
        case .compact: return .compact
        case .regular: return .regular
        default: return nil
        }
        #else
        return .regular // macOS 默认 regular
        #endif
    }

    /// 与上面同一个入口，但可以**不惊动静默窗**。
    ///
    /// - Parameter shouldPoke: 受理后是否叫醒静默窗。提交途中的重投（`retryRejectedRowContentWidths()`）
    ///   传 false：那笔量测之所以成立，正是因为本次提交刚把新的画布写进去，由呼叫端在同一个提交里落定；
    ///   若再叫醒静默窗，同一笔量测要多花一趟 0.7 秒的往返与一次多余的提交。
    private func reportListRowContentWidth(
        _ width: CGFloat,
        for column: ListRowColumn,
        pokingTheSettleWindow shouldPoke: Bool
    ) {
        let rounded = max(width.rounded(.down), 0)
        guard rounded > 0 else { return }
        var didChange = false
        switch column {
        case .sidebar:
            // 清单列不可能比它所在的栏位画布还宽：更宽的量测必然来自上一个排版世代
            // （例如侧栏正在收起时，页面曾按整窗宽排版）。这种量测若被发布出去，消费端会
            // 算出比实际更多的栏数，固定尺寸的卡片就会互相重叠。
            // 比较对象用**同一世代**的 pending 画布，而不是已提交的画布：后者本身可能还停在
            // 上一世代，拿它当门槛会把这一世代正确的量测也一并丢掉。
            let canvas = pendingSidebarWidth ?? stagedSidebarWidth ?? actualSidebarWidthObserved
            if isStaleRowWidthMeasurement(rounded, canvasWidth: canvas, columnName: "sidebar") {
                // 丢掉但记着：栏位画布一更新就重投（见 `retryRejectedRowContentWidths()`）。
                rejectedSidebarRowContentWidth = rounded
                return
            }
            rejectedSidebarRowContentWidth = nil
            guard (pendingSidebarRowContentWidth ?? stagedSidebarRowContentWidth ?? sidebarRowContentWidth) != rounded
            else { return }
            lastReportedSidebarRowContentWidth = rounded
            pendingSidebarRowContentWidth = rounded
            didChange = true
        case .mainColumn:
            // - Important: 残量判定用的画布必须是**即时**主栏可用宽，不能是主栏实测宽。
            //
            // 实测主栏宽只在主栏真的重测时才更新；铰链 halfOpen ↔ fullyOpen 这类「窗口 / 侧栏变了、
            // 主栏没重测」的转换里它是旧世代的残量（实测恒为 372）。拿它当画布，会把「窗变宽之后
            // 量到的新内容宽」一律判成残量而丢弃，而 `reportListRowContentWidth()` 只在宽度**变化**
            // 时才被叫用，丢掉就没人回来补发 —— 消费端（`CharInventoryView` 的每行格数）于是永远不更新。
            let canvas = mainColumnRowWidthCanvas
            if isStaleRowWidthMeasurement(rounded, canvasWidth: canvas, columnName: "mainColumn") {
                rejectedMainColumnRowContentWidth = rounded
                return
            }
            guard (pendingMainColumnRowContentWidth ?? stagedMainColumnRowContentWidth ?? mainColumnRowContentWidth) !=
                rounded
            else { return }
            // 清掉待重投的量测要在「确认这一笔真的被受理」之后：否则当前值的重复回报会把一笔
            // 更宽、只是暂时比旧画布宽的量测顺手抹掉（实测：一笔 309 的重报把 pending 的 485 抹掉）。
            rejectedMainColumnRowContentWidth = nil
            lastReportedMainColumnRowContentWidth = rounded
            pendingMainColumnRowContentWidth = rounded
            didChange = true
        }
        guard didChange else { return }
        // - Important: 首次量到的内容宽**立刻发布**，不等提交。
        //
        // 消费端（Specimen / 战报 / 角色清单 / 抽卡图表 / 桌布廊）在环境值还是 nil 时，
        // 会退回「即时画布 − 内缩」自行推算。那条退路读的是**当下**画布，因此一次旋转里
        // 它会跟着中间世代抖动，正是要消掉的那份「多段重排」。先在这里把首帧值补上，
        // 环境值此后永远非 nil，退路就不再有实际戏份。
        if mainColumnRowContentWidth <= 0, let seeded = pendingMainColumnRowContentWidth {
            mainColumnRowContentWidth = seeded
        }
        if sidebarRowContentWidth <= 0, let seeded = pendingSidebarRowContentWidth {
            sidebarRowContentWidth = seeded
        }
        guard shouldPoke else { return }
        reportLayoutStateObservation()
    }

    /// 判断一次「清单列可用内容宽」的量测是不是上一个排版世代的残留。
    ///
    /// 画布宽尚未量到时（启动阶段）一律接受，否则会把最先到的量测全部丢掉。
    private func isStaleRowWidthMeasurement(
        _ measured: CGFloat,
        canvasWidth: CGFloat,
        columnName: String
    )
        -> Bool {
        guard canvasWidth > 0 else { return false }
        let isStale = measured > canvasWidth.rounded(.up)
        #if DEBUG
        if isStale {
            PZLog.info("ignored a stale \(columnName) row-width measurement: \(measured) > canvas \(canvasWidth)")
        }
        #endif
        return isStale
    }

    /// 重新投递先前因「比当世代画布还宽」而被丢弃的内容宽量测。
    ///
    /// 呼叫时机：任一个「栏位画布」观测更新之后。画布一变宽，先前那笔量测就不再是残量，
    /// 而这个时机是唯一能补救它的场合——`reportListRowContentWidth()` 只在宽度变化时才被叫用，
    /// 不会自己再回来重试。
    ///
    /// - Important: 重投本身**不叫醒静默窗**，它只把一笔量测写进 pending 槽。观测更新路径的呼叫端
    ///   紧接着就会叫醒（它自己会 poke）；提交路径的呼叫端则在同一个提交里直接落定，不再多走一趟往返。
    ///
    /// - Returns: 是否真的重投了东西。
    @discardableResult
    private func retryRejectedRowContentWidths() -> Bool {
        var didRetry = false
        if let rejected = rejectedSidebarRowContentWidth {
            rejectedSidebarRowContentWidth = nil
            reportListRowContentWidth(rejected, for: .sidebar, pokingTheSettleWindow: false)
            didRetry = true
        }
        if let rejected = rejectedMainColumnRowContentWidth {
            rejectedMainColumnRowContentWidth = nil
            reportListRowContentWidth(rejected, for: .mainColumn, pokingTheSettleWindow: false)
            didRetry = true
        }
        return didRetry
    }

    /// 作废「比刚提交的栏位画布还宽」的已发布内容宽。
    ///
    /// 已发布的宽度可能是在「栏位还比较宽」的排版世代量到的：侧栏之后若出现（画布由整窗缩到栏内），
    /// 那个旧值就会比当前画布还宽。消费端拿它算栏数会算出装不下的栏数，固定尺寸的卡片于是互相重叠
    /// （ID Photo Specimen 页曾如此卡住）。作废之后消费端会退用自己的保守估值（画布减固定内缩量），
    /// 等新的量测落定再发布一次。
    private func invalidateRowContentWidthsExceedingCanvas() {
        // 比较对象必须与 `reportListRowContentWidth()` 的残量判定用**同一个**量：即时主栏可用宽。
        //
        // 这里一度改用主栏实测宽（`mainColumnSizeObservedSansBleed`），理由是它才代表 detail 栏的
        // 真实宽度。但那个值只在主栏真的重测时才更新，铰链开合时它停在旧世代（实测恒为 372），
        // 于是一笔刚发布、实际装得下的内容宽会在同一次提交末尾被作废成 0。而
        // `reportListRowContentWidth()` 只在量到的宽度变化时才被叫用，作废后没人回来补发，
        // 消费端便永远停在「画布减固定内缩量」的退路估值上——ID Photo Specimen 的栏数不更新、
        // 卡片互相重叠即源于此。两侧统一用即时画布后，误判作废的通道就不存在了。
        let sidebarCanvas = pendingSidebarWidth ?? stagedSidebarWidth ?? actualSidebarWidthObserved
        if sidebarCanvas > 0, sidebarRowContentWidth > sidebarCanvas {
            #if DEBUG
            PZLog.info("invalidated sidebar row width \(sidebarRowContentWidth) > canvas \(sidebarCanvas)")
            #endif
            sidebarRowContentWidth = 0
        }
        let mainCanvas = mainColumnRowWidthCanvas
        if mainCanvas > 0, mainColumnRowContentWidth > mainCanvas {
            #if DEBUG
            PZLog.info("invalidated mainColumn row width \(mainColumnRowContentWidth) > canvas \(mainCanvas)")
            #endif
            mainColumnRowContentWidth = 0
        }
    }

    /// 按住内容宽时排定的一次补提交。
    ///
    /// 必须有它：静默窗提交若刚好撞上边栏可见性翻转，那一刻内容宽会被按住；而这次提交之后
    /// 观测流已经静下来，不会有下一笔观测来触发下一次提交——少了补提交，新宽度就永远发不出去。
    /// 补提交只在「排定之后确实没有任何新观测」时才动手，否则交给正常的静默窗去落定。
    private func scheduleRowContentWidthReleaseIfNeeded() {
        guard deferredRowContentWidth else { return }
        guard rowContentWidthReleaseTask == nil else { return }
        rowContentWidthReleaseTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let delay = layoutSettleDelay
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            rowContentWidthReleaseTask = nil
            // `lastObservationAt` 在每次提交时被清成 nil；它仍非 nil 就代表又来了新观测，
            // 那一轮自然会由静默窗落定，这里不抢。
            guard lastObservationAt == nil else { return }
            lastObservationLooksSettled = true
            await commitLayoutState()
        }
    }

    /// 立刻记录并提交一次（不等静默窗）。用于铰链开阖翻转这种必须即时生效的场合。
    private func recordPendingObservationsImmediately() {
        // 刻意**不取消**计时任务：`recordPendingObservations()` 会在第一个 await 之前就把 pending
        // 槽清空，取消一个已经越过最后一个停止点的任务无法阻止那次提交，反而取消一个还没越过
        // 停止点的任务会留下「pending 已被耗尽」的空窗。`reportLayoutStateObservation()` 的闸门
        // 已保证同时只有一个计时任务，这里直接提交即可。
        observationRecordStartedAt = nil
        lastObservationAt = nil
        // 立即提交意味着观测流没有停下来：这次手里的内容宽不算静定态。
        lastObservationLooksSettled = false
        Task { @MainActor [weak self] in
            await self?.recordPendingObservations()
        }
    }

    /// 把静下来的原始观测「记录」下来：pending → staged 快照，随即提交一次。
    ///
    /// 由 `reportLayoutStateObservation()` 的静默窗触发（铰链开阖翻转时则直接调用，以求即时）。记录是**整批**做的：
    /// 同一场排版里的窗口、侧栏、主栏与方向值因此永远取自同一世代，派生值（padding offset）也就不会
    /// 混用世代而算出荒谬结果。
    private func recordPendingObservations() async {
        if let value = pendingOrientation { stagedOrientation = value; pendingOrientation = nil }
        if let value = pendingHinge { stagedHinge = value; pendingHinge = nil }
        if let value = pendingIsHorizontallyCompact {
            stagedIsHorizontallyCompact = value
            pendingIsHorizontallyCompact = nil
        }
        if let value = pendingWindowSize { stagedWindowSize = value; pendingWindowSize = nil }
        if let value = pendingWindowSizeSansBleed {
            stagedWindowSizeSansBleed = value
            pendingWindowSizeSansBleed = nil
        }
        if let value = pendingSidebarWidth { stagedSidebarWidth = value; pendingSidebarWidth = nil }
        // 这一世代是否真的重测了主栏宽。必须在清空 pending 之前取，见
        // `recordSidebarPaddingOffset(didMeasureMainColumn:)`。
        let didMeasureMainColumn = pendingMainColumnSansBleed != nil
        if let value = pendingMainColumnSansBleed {
            stagedMainColumnSansBleed = value
            pendingMainColumnSansBleed = nil
        }
        if let value = pendingMainColumnWithBleed {
            stagedMainColumnWithBleed = value
            pendingMainColumnWithBleed = nil
        }
        if let value = pendingSidebarRowContentWidth {
            stagedSidebarRowContentWidth = value
            pendingSidebarRowContentWidth = nil
        }
        if let value = pendingMainColumnRowContentWidth {
            stagedMainColumnRowContentWidth = value
            pendingMainColumnRowContentWidth = nil
        }
        recordSidebarPaddingOffset(didMeasureMainColumn: didMeasureMainColumn)
        await commitLayoutState()
    }

    /// 由**同一批已记录**的观测推算 split view 的 sidebar padding offset。
    ///
    /// offset ＝（窗口宽 − 侧栏宽）− 主栏实测宽。三者若取自不同排版世代，会算出荒谬的值
    /// （启动阶段曾因此得到 404，进而让 `mainColumnCanvasSizeObserved` 只有 227）。
    /// 窗口宽必须用**整窗**值：`windowSizeObservedSansBleed` 已经扣掉出血（951 → 867），
    /// 拿它减侧栏宽会算出 0 这种假 offset。
    ///
    /// - Parameter didMeasureMainColumn: 这一世代的主栏宽是否**重新量测过**。
    ///
    ///   - Important: offset 只在主栏真的重测时才重算。否则 `mainColumn` 是旧世代的残量，
    ///     重算只会把「窗口 / 侧栏」的变化整包吸收进 offset，而
    ///     `mainColumnCanvasSizeObserved ≡ 窗口宽 − 侧栏宽 − offset` 又会把它们还原回去——
    ///     两者互为逆运算，画布于是恒等于**上一次主栏实测宽**，任何几何变化都传不到消费端
    ///     （铰链 halfOpen ↔ fullyOpen 时 `CharInventoryView` 的每行格数不更新即源于此）。
    private func recordSidebarPaddingOffset(didMeasureMainColumn: Bool) {
        guard let mainColumn = stagedMainColumnSansBleed else { return }
        let sidebarWidth = (stagedSidebarWidth ?? actualSidebarWidthObserved).rounded(.up)
        let windowWidth = (stagedWindowSize ?? windowSizeObserved).width.rounded(.up)
        let computedWidth = windowWidth - sidebarWidth
        guard computedWidth > 0, sidebarWidth > 0 else { return }
        guard didMeasureMainColumn || stagedSidebarPaddingOffset == nil else { return }
        stagedSidebarPaddingOffset = max(0, (computedWidth - mainColumn.width.rounded(.up)).rounded(.up))
    }

    /// 提交一次排版状态：把 staged 的观测落定成消费端可见的值，再重算 sidebar 可见性。
    /// 见 `reportLayoutStateObservation()`。
    private func commitLayoutState() async {
        // 几何先落定，再判断这次提交会不会翻转边栏可见性。
        // 顺序不能反：`splitViewVisibilityAfterCommit()` 要看 `isHorizontallyCompact` /
        // `orientation` / `hingeStatus` / `windowSizeObserved`，这些若还停在上一世代，
        // 预测出来的可见性就是错的，延后逻辑会整个失效。
        let geometryBefore = committedGeometry
        applyStagedObservations()
        let geometryDidChange = geometryBefore != committedGeometry

        // 边栏可见性翻转的那一次提交，内容宽一律不落定。
        //
        // 理由就是使用者描述的那串时序：A（铰链/旋转）→ C1（主栏画布变）→ D1（内容重排）
        // → B（边栏开关）→ C2 → D2。C1 那次提交手上的内容宽，是在「边栏还没动画完」的
        // 几何下量到的过渡态；一旦发布，消费端就照它先重排一次（D1），等 B/C2 落定再重排
        // 一次（D2）——于是使用者看到「动画分了好几步、最后卡在最终动作」。
        // 这一版把它按住：只要这次提交会改变 `splitViewVisibility`，内容宽就不发布，
        // 由下一个世代（边栏动画结束、追踪器重新回报之后）的那次提交一次落定。
        let visibilityChangesNow = splitViewVisibilityAfterCommit() != splitViewVisibility
        // 过渡刚起头（还没静默满一个 `layoutSettleDelay`）时也按住：B 可能还在几拍之后。
        let transitionHasSettled = layoutTransitionArmedAt
            .map { Date().timeIntervalSince($0) >= layoutSettleDelay } ?? true
        // 关键的一条：观测流没停下来时一律按住。
        //
        // 只盯「这次提交会不会翻转可见性」是不够的——旋转过程中 `maxDelay` 上限会强制提交
        // 好几次，那几次的 `visibilityChangesNow` 早就是 false 了，手上的内容宽却还是边栏
        // 动画中途量到的过渡值；发出去正是 D1。真正可信的信号只有一个：静默窗是自然到期的
        // （观测流确实停了一个 `layoutSettleDelay`），几何才真的静止。
        if visibilityChangesNow || !transitionHasSettled || !lastObservationLooksSettled {
            deferredRowContentWidth = true
        } else {
            deferredRowContentWidth = false
            rowContentWidthReleaseTask?.cancel()
            rowContentWidthReleaseTask = nil
            applyStagedRowContentWidthsIfNeeded()
        }
        // 还有一笔内容宽等着落定吗（`staged…` 与已落定值不同）。
        //
        // 早退判据必须带上它：`applyStagedRowContentWidthsIfNeeded()` 只在上面「非延后」分支里跑，
        // 若这次提交的差事就是发布它，早退掉就再也没有下一次提交来发布。
        let rowContentWidthPublishPending = (stagedSidebarRowContentWidth.map { $0 != sidebarRowContentWidth } ?? false)
            || (stagedMainColumnRowContentWidth.map { $0 != mainColumnRowContentWidth } ?? false)
        // 这次提交无事可做就直接结束。
        //
        // 实测一次旋转 / 折合会留下 2–3 笔「每个字段都与上一次完全相同」的提交：跟踪器在过渡尾巴上又回报了
        // 一轮同样的尺寸，静默窗于是重新计时并再提交一次。它们不写任何 `@Observable` 属性、因此不会造成
        // 重绘，却会白跑一次提交、留下一行一模一样的诊断，也让「一次事件触发几次提交」这个指标失真。
        //
        // 判据必须严格：内容宽还等着落定、观测流还没静定（这次提交得把 `deferredRowContentWidth` 立起来）、
        // 或正处于延后中（`scheduleRowContentWidthReleaseIfNeeded()` 的补提交还没排）时都不能提早结束。
        if !geometryDidChange, !rowContentWidthPublishPending, !visibilityChangesNow,
           !deferredRowContentWidth, transitionHasSettled, lastObservationLooksSettled {
            return
        }
        scheduleRowContentWidthReleaseIfNeeded()

        applySplitViewVisibilityIfNeeded()

        updateHash4Tracking()
        // 延后期间刻意不清理内容宽：清理会把已发布值归零，环境值一变 nil，消费端就退回
        // 「即时画布 − 内缩」的推算路径，等于绕个弯又把过渡世代放进来。这里宁可让手上这份
        // 旧值多留一个提交的时间：网格的输入宽不变，它就不会重排，正好是「边栏动画期间先按住、
        // 收尾时一次结算」。延后一定会在下一个提交结束（`splitViewVisibility` 一变就必然触发
        // 重排，追踪器随之回报），因此这段不一致是有界的。
        if !deferredRowContentWidth {
            invalidateRowContentWidthsExceedingCanvas()
            // 画布刚落定：把先前被误判为残量的内容宽重投一次。
            //
            // 这个时机才是对的。栏位量测当下（`handleTrackedSidebarCanvasSize()` 等）触发的那次重投
            // 读到的仍是**旧世代**画布，必然再被丢弃一次；只有等本次提交把新的窗口 / 侧栏写进去之后
            // 重投，那笔更宽的量测才会被受理（见 `mainColumnRowWidthCanvas`）。
            //
            // 重投的那笔就地落定（重投写 pending，这里顺手收进 staged 再发布），不等静默窗——否则同一笔
            // 量测要再多花一趟 0.7 秒的往返与一次额外提交。
            if retryRejectedRowContentWidths() {
                if let value = pendingSidebarRowContentWidth {
                    stagedSidebarRowContentWidth = value
                    pendingSidebarRowContentWidth = nil
                }
                if let value = pendingMainColumnRowContentWidth {
                    stagedMainColumnRowContentWidth = value
                    pendingMainColumnRowContentWidth = nil
                }
                applyStagedRowContentWidthsIfNeeded()
            }
        }
        // 已公布的内容宽一律夹到当前画布以内（延后期间也夹，见该函式的说明）：延后期间手上留的是上一代
        // 的量测，新姿态的画布更窄时它会宽于画布，消费端据此算栏数就会让固定尺寸的卡片溢出重叠。
        //
        // 放在所有发布路径之后，上面重投落定的那一笔也在夹的范围内。
        clampPublishedRowContentWidthsToCanvas()
        #if DEBUG
        // 诊断用：一次旋转 / 铰链开合到底触发了几次提交、每次提交消费端看到的值是什么。
        PZLog.info(
            "layout commit: win=\(Int(windowSizeObserved.width))×\(Int(windowSizeObserved.height))"
                + ", side=\(Int(actualSidebarWidthObserved)), offset=\(Int(mainColumnSidebarPaddingOffset))"
                + ", sansBleed=\(Int(windowSizeObservedSansBleed.width))×\(Int(windowSizeObservedSansBleed.height))"
                + ", canvas=\(Int(mainColumnCanvasSizeObserved.width))"
                + ", rowMain=\(Int(mainColumnRowContentWidth)), rowSide=\(Int(sidebarRowContentWidth))"
                + ", hingeOpen=\(isHingeOpen), compact=\(isHorizontallyCompact)"
                + ", phonePortrait=\(isPhonePortraitSituation)"
                + ", vis=\(String(describing: splitViewVisibility))"
        )
        #endif
    }

    /// 把 staged 的几何观测写进消费端可见的属性。
    ///
    /// 值没变就不写：`@Observable` 对每次赋值都会发通知，重复写入只会制造多余的重绘。
    /// 「清单列可用内容宽」不在这里落定，由 `commitLayoutState()` 依可见性是否翻转单独决定
    /// （见该处的说明）。
    private func applyStagedObservations() {
        if let stagedOrientation, orientation != stagedOrientation {
            orientation = stagedOrientation
        }
        if let stagedHinge {
            if hingeStatus != stagedHinge.status {
                hingeStatus = stagedHinge.status
                // 铰链暂定值只在**落定时**才落盘。扳动铰链时角度每次回呼都不同（可达 60Hz），
                // 若在 pending 阶段就写，一次折合会产生上百次 `UserDefaults` 写入。这个值只用于
                // 下次启动的暂定值（首次回呼约 0.9 秒后才到，粒度本来就粗），因此延后到提交、
                // 并且只存四舍五入到整度的角度即可。
                Defaults[.lastKnownHingeStatus] = stagedHinge.status?.rawValue
            }
            if hingeAngleInDegrees != stagedHinge.angleInDegrees {
                hingeAngleInDegrees = stagedHinge.angleInDegrees
                Defaults[.lastKnownHingeAngleInDegrees] = stagedHinge.angleInDegrees.map { $0.rounded() }
            }
        }
        if let stagedIsHorizontallyCompact, isHorizontallyCompact != stagedIsHorizontallyCompact {
            isHorizontallyCompact = stagedIsHorizontallyCompact
        }
        if let stagedWindowSize, windowSizeObserved != stagedWindowSize {
            windowSizeObserved = stagedWindowSize
        }
        if let stagedWindowSizeSansBleed, windowSizeObservedSansBleed != stagedWindowSizeSansBleed {
            windowSizeObservedSansBleed = stagedWindowSizeSansBleed
        }
        if let stagedSidebarWidth, actualSidebarWidthObserved != stagedSidebarWidth {
            actualSidebarWidthObserved = stagedSidebarWidth
        }
        if let stagedMainColumnSansBleed, mainColumnSizeObservedSansBleed != stagedMainColumnSansBleed {
            mainColumnSizeObservedSansBleed = stagedMainColumnSansBleed
        }
        if let stagedMainColumnWithBleed, mainColumnSizeObservedWithBleed != stagedMainColumnWithBleed {
            mainColumnSizeObservedWithBleed = stagedMainColumnWithBleed
        }
        if let stagedSidebarPaddingOffset, mainColumnSidebarPaddingOffset != stagedSidebarPaddingOffset {
            mainColumnSidebarPaddingOffset = stagedSidebarPaddingOffset
        }
    }

    /// 把 staged 的「清单列可用内容宽」落定成消费端可见的值。
    ///
    /// 与几何分开是为了让内容宽可以延后一拍落定（见 `commitLayoutState()`）。
    private func applyStagedRowContentWidthsIfNeeded() {
        if let stagedSidebarRowContentWidth, sidebarRowContentWidth != stagedSidebarRowContentWidth {
            sidebarRowContentWidth = stagedSidebarRowContentWidth
        }
        if let stagedMainColumnRowContentWidth, mainColumnRowContentWidth != stagedMainColumnRowContentWidth {
            mainColumnRowContentWidth = stagedMainColumnRowContentWidth
        }
    }

    /// 把「已公布」的清单列可用内容宽夹到当前画布以内。
    ///
    /// 过渡期间多数提交走的是延后路径（见 `commitLayoutState()`），内容宽还没轮到落定，消费端手上留着的是
    /// **上一代**的量测值；若新姿态的画布更窄，那个值就会比画布还宽，消费端拿它去算栏数，固定尺寸的卡片
    /// 便溢出重叠（2026-10-08 记录的「rowMain=807 配 canvas=372」正是这个形态）。
    ///
    /// - Important: 只夹**已公布**的衍生值，`staged…` 里的真实量测原封不动，画布一宽回来就会照原值公布；
    /// 因此过渡期间最多短暂偏窄（栏数只会少、不会多），不会重叠。
    ///
    ///   上界取**已落定**的 `mainColumnCanvasSizeObserved` / `actualSidebarWidthObserved`，也就是消费端
    ///   此刻真的会看到的画布（诊断行印的 `canvas=` 正是前者）。这比残量判定用的 `mainColumnRowWidthCanvas`
    ///   更紧——那个刻意取 pending 优先的较宽值、宁可放宽也不误杀（见其说明）；夹的职责不同：它保证
    ///   「发出去的值装得进当下这块画布」。
    private func clampPublishedRowContentWidthsToCanvas() {
        if actualSidebarWidthObserved > 0 {
            let clamped = min(sidebarRowContentWidth, actualSidebarWidthObserved)
            if sidebarRowContentWidth != clamped {
                sidebarRowContentWidth = clamped
            }
        }
        if mainColumnCanvasSizeObserved.width > 0 {
            let clamped = min(mainColumnRowContentWidth, mainColumnCanvasSizeObserved.width)
            if mainColumnRowContentWidth != clamped {
                mainColumnRowContentWidth = clamped
            }
        }
    }

    /// 按当前（已落定的）几何与铰链状态算出这次提交该显示的边栏可见性。
    private func splitViewVisibilityAfterCommit() -> NavigationSplitViewVisibility {
        if OS.type == .macOS {
            // 似乎在 iOS 系统下没有办法停用与边栏有关的出入动画；macOS 则固定显示边栏。
            return .all
        }
        // 边栏是否显示交给 `shouldShowSidebar` 单点判定（铰链张开时改看视窗长宽比）。
        let isCompactWidth = isHorizontallyCompact
        return shouldShowSidebar(isCompactWidth: isCompactWidth) ? .all : .detailOnly
    }

    /// 依 `splitViewVisibilityAfterCommit()` 的结果更新边栏可见性；变了才写。
    private func applySplitViewVisibilityIfNeeded() {
        if OS.type == .macOS {
            applySplitViewVisibility(.all, reason: "macOS")
            return
        }
        let isCompactWidth = isHorizontallyCompact
        let showsSidebar = shouldShowSidebar(isCompactWidth: isCompactWidth)
        let windowSize = windowSizeObserved
        let windowSizeRAW = "\(Int(windowSize.width))×\(Int(windowSize.height))"
        let hingeNote = windowSize.width > windowSize.height ? "比高宽" : "比宽高"
        let reason: String = isHingeOpen
            ? "铰链张开：占满萤幕 \(isAppOccupyingWholeScreen)，视窗 \(windowSizeRAW)（\(hingeNote)）"
            : "铰链未张开：\(orientation.rawValue)，compact 宽度 \(isCompactWidth)"
        applySplitViewVisibility(showsSidebar ? .all : .detailOnly, reason: reason)
    }

    private func applySplitViewVisibility(
        _ newValue: NavigationSplitViewVisibility,
        reason: String
    ) {
        guard splitViewVisibility != newValue else { return }
        splitViewVisibility = newValue
        PZLog.info("splitViewVisibility 更新为 \(String(describing: newValue))（\(reason)）")
    }

    /// 把铰链观测 stage 起来；真正落定于 `commitLayoutState()`。
    private func applyHingeObservation(status newStatus: HingeStatus?, angleInDegrees newAngleInDegrees: Double?) {
        let previous = pendingHinge ?? stagedHinge ?? .init(status: hingeStatus, angleInDegrees: hingeAngleInDegrees)
        guard previous.status != newStatus || previous.angleInDegrees != newAngleInDegrees else { return }
        let wasOpen = Self.isHingeOpen(status: previous.status, angleInDegrees: previous.angleInDegrees)
        let isOpenNow = Self.isHingeOpen(status: newStatus, angleInDegrees: newAngleInDegrees)
        pendingHinge = .init(status: newStatus, angleInDegrees: newAngleInDegrees)
        if previous.status != newStatus {
            // A：铰链开阖翻转，同样是一次排版过渡的起点。
            layoutTransitionArmedAt = Date()
        }
        // 铰链暂定值的 `UserDefaults` 落盘延后到 `applyStagedObservations()`：这条路径在扳动
        // 铰链时是高频的（角度每次回呼都不同），见该处的说明。
        reportLayoutStateObservation()
        // 角度会在高频扳动时变化，因此只在开阖状态改变时才写日志。
        guard previous.status != newStatus || wasOpen != isOpenNow else { return }
        let angleText = newAngleInDegrees.map { "\(($0 * 10).rounded() / 10)°" } ?? "nil"
        PZLog.info("铰链状态: \(newStatus?.rawValue ?? "nil"), 角度: \(angleText)")
    }

    private func updateHash4Tracking() {
        var hasher = Hasher()
        hasher.combine(orientation)
        hasher.combine(hingeStatus)
        hasher.combine(isHorizontallyCompact)
        hasher.combine(actualSidebarWidthObserved)
        hasher.combine(windowSizeObserved.width)
        hasher.combine(windowSizeObserved.height)
        hasher.combine(mainColumnSidebarPaddingOffset)
        hasher.combine(mainColumnSizeObservedSansBleed.width)
        hashForTracking = hasher.finalize()
    }

    private func registerObservation() {
        withObservationTracking {
            // _ = orientation <- 无须重複观测 orientation。
            _ = hingeStatus
            _ = isHorizontallyCompact
            _ = actualSidebarWidthObserved
            _ = mainColumnSizeObservedSansBleed
            _ = windowSizeObserved.hashValue
            _ = mainColumnSidebarPaddingOffset
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let this = self else { return }
                // 只需要更新追踪哈希：提交动作由各个回报入口 poke；
                // 若在这里再 poke 一次，每次提交都会多绕一圈去抖。
                this.updateHash4Tracking()
                this.registerObservation()
            }
        }
    }
}

// MARK: - ListRowContentWidthKey

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
private struct ListRowContentWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension EnvironmentValues {
    /// 当前栏位中 `Form` / `List` 单行内容区的**实测可用宽**（`ScreenVM` 已提交的值）。
    /// 由 `ContentView` 依栏位注入（Sidebar 栏给 `ScreenVM.sidebarRowContentWidth`、
    /// Main Column 给 `mainColumnRowContentWidth`）。
    /// 为 `nil` 表示尚未量到（首帧），消费端应退回自己的保守估值。
    public var listRowContentWidth: CGFloat? {
        get { self[ListRowContentWidthKey.self] }
        set { self[ListRowContentWidthKey.self] = newValue }
    }
}

// MARK: - ListRowColumnKey

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
private struct ListRowColumnKey: EnvironmentKey {
    static let defaultValue: ScreenVM.ListRowColumn = .mainColumn
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension EnvironmentValues {
    /// 当前画面所在的栏位：`View.reportListRowContentWidth()` 用它决定把量到的宽度回报给哪一栏。
    public var listRowColumn: ScreenVM.ListRowColumn {
        get { self[ListRowColumnKey.self] }
        set { self[ListRowColumnKey.self] = newValue }
    }
}

// MARK: - UIWindowScene Orientation Extension

#if os(iOS) && !targetEnvironment(macCatalyst)
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension UIInterfaceOrientation {
    var screenVMOrientation: ScreenVM.Orientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portrait
        // 注意：UIInterfaceOrientation 和 UIDeviceOrientation 方向相反
        case .landscapeLeft: return .landscape
        case .landscapeRight: return .landscape
        default: return .portrait
        }
    }
}
#endif

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension ScreenVM {
    public static func getKeyWindowSize() -> CGSize {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.frame.size ?? .init(width: 375, height: 667)
        #elseif canImport(AppKit)
        return NSApplication.shared.keyWindow?.frame.size ?? .init(width: 375, height: 667)
        #else
        return .init(width: 375, height: 667)
        #endif
    }

    /// 取得当前所在萤幕的完整尺寸（整个显示范围，而非 App 视窗范围）。
    public static func getScreenSize() -> CGSize {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.bounds.size }
            .first ?? .init(width: 375, height: 667)
        #elseif canImport(AppKit)
        return NSScreen.main?.frame.size ?? .init(width: 375, height: 667)
        #else
        return .init(width: 375, height: 667)
        #endif
    }
}

// MARK: - ScreenVM.ViewTracker

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension ScreenVM {
    fileprivate struct ViewTracker: ViewModifier {
        // MARK: Lifecycle

        public init(debounceDelay: TimeInterval = 0.05) {
            self.debounceDelay = debounceDelay
        }

        // MARK: Public

        public var combinedHash: Int {
            var hasher = Hasher()
            hasher.combine(horizontalSizeClass ?? .regular)
            hasher.combine(screenVM.hashForTracking)
            return hasher.finalize()
        }

        public func body(content: Content) -> some View {
            content
                // 本 tracker 维护的是「视窗尺寸」，所以连 `.container` 这类含出血边界的
                // 安全区也一并计入（`.all` 边）。iPhone Duo 展开时系统会在尾端留一条
                // vertical bar 安全区（实测 84pt，下缘另有 34pt），若不这么做，
                // windowSizeObserved 会比视窗窄一整条，导致依赖它的背景出血范围
                // （例如 AvatarStatCollectionTabView）覆盖不到该区域。
                // `.keyboard` 刻意不计入：键盘弹出时视窗本身并没有变。
                .trackCanvasSize(
                    debounceDelay: debounceDelay,
                    includingSafeArea: .container,
                    edges: .all
                ) { newSizeRAW in
                    let newSize = newSizeRAW
                    screenVM.reportWindowSize(newSize)
                }
                .onAppBecomeActive {
                    Task {
                        await pushTrackedPropertiesToScreenVM()
                    }
                }
                .task {
                    // 这里只负责立即推一次已追踪的参数，不再用 `getKeyWindowSize()` 覆写
                    // `windowSizeObserved`：该 API 在启动阶段可能取到尚未就绪的 key window
                    // 而回传虚假值（375×667 之类），会盖掉 tracker 量到的正确视窗尺寸
                    // （含安全区的出血边界，见上方 `trackCanvasSize` 的说明）。
                    await pushTrackedPropertiesToScreenVM() // 立即执行
                }
                .react(to: combinedHash, initial: true) { _, _ in
                    Task {
                        await pushTrackedPropertiesToScreenVM()
                    }
                }
                .trackDeviceHinge()
        }

        // MARK: Private

        @State private var screenVM: ScreenVM = .shared
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

        private let debounceDelay: TimeInterval

        /// 这里不再自带去抖器：视窗尺寸的观测去抖由 `trackCanvasSize` 负责，
        /// 而「排版状态」的提交去抖由 `ScreenVM.reportLayoutStateObservation()` 统一负责。
        /// 原本两层去抖（本层 0.1s ＋ 提交层 0.35s）会让一次旋转 / 铰链开合多绕一圈。
        private func pushTrackedPropertiesToScreenVM() async {
            syncLayoutParamsToBackend()
            // 边栏可见性改由 `ScreenVM` 统一提交（与各栏宽度快照同一次落定），
            // 这里只负责把所有观测汇总过去。
            screenVM.reportLayoutStateObservation()
        }

        private func syncLayoutParamsToBackend() {
            screenVM.reportHorizontalSizeClass(isCompact: (horizontalSizeClass ?? .regular) == .compact)
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension View {
    @ViewBuilder
    public func trackScreenVMParameters(debounceDelay: TimeInterval = 0.05) -> some View {
        modifier(ScreenVM.ViewTracker(debounceDelay: debounceDelay))
    }
}

// MARK: - DeviceHinge Tracking

#if os(iOS) && !targetEnvironment(macCatalyst)
/// 观察折叠装置（例如 iPhone Duo）的铰链状态，并回报给 `ScreenVM`。
@available(iOS 27.1, macCatalyst 27.1, *)
private struct DeviceHingeTrackingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onHingeChange { _, newContext in
            let newStatus = ScreenVM.HingeStatus(hinge: newContext.hinge)
            let newAngleInDegrees = newContext.hinge?.angle.degrees
            Task { @MainActor in
                ScreenVM.shared.reportHingeObservation(status: newStatus, angleInDegrees: newAngleInDegrees)
            }
        }
    }
}

@available(iOS 27.1, macCatalyst 27.1, *)
extension ScreenVM.HingeStatus {
    /// 由 SwiftUI 的 `DeviceHinge` 映射而来；`nil` 表示该层级不提供铰链资讯。
    init?(hinge: DeviceHinge?) {
        guard let hinge else { return nil }
        switch hinge.status {
        case .closed: self = .closed
        case .partiallyOpen: self = .partiallyOpen
        case .fullyOpen: self = .fullyOpen
        default: self = .unknown
        }
    }

    /// 由 UIKit 的 `UIHinge` 映射而来；`nil` 表示该层级不提供铰链资讯。
    @MainActor
    init?(hinge: UIHinge?) {
        guard let hinge else { return nil }
        switch hinge.status {
        case .unknown: self = .unknown
        case .closed: self = .closed
        case .partiallyOpen: self = .partiallyOpen
        case .fullyOpen: self = .fullyOpen
        @unknown default: self = .unknown
        }
    }
}
#endif

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension View {
    /// 观察折叠装置（例如 iPhone Duo）的铰链状态。
    ///
    /// 这套 SwiftUI API 只随书本式铰链（目前尚仅 iPhone Duo）提供；
    /// MacBook 的铰链并未被设计成 SwiftUI 的 hinge API。
    /// 因此 macCatalyst 与 AppKit 建置目标一律以编译期条件排除，
    /// 它们在拿不到铰链资讯时的行为与既有逻辑一致。
    @ViewBuilder
    public func trackDeviceHinge() -> some View {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, macCatalyst 27.1, *) {
            modifier(DeviceHingeTrackingModifier())
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// MARK: - EarlyHinge Tracking (UIKit)

#if os(iOS) && !targetEnvironment(macCatalyst)
@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension ScreenVM {
    /// 尽早在 App 启动阶段开始观察铰链：把 `UIHingeInteraction` 挂到 key window 上，
    /// 这样首屏的 `splitViewVisibility` 判定就能直接用到铰链状态，
    /// 不必等 SwiftUI 的 `.onHingeChange` 随视图挂载才回呼（实测晚了约 0.9 秒）。
    ///
    /// 两者同源、回报内容一致（两条路径都走 `reportHingeObservation(status:angleInDegrees:)`，
    /// 该入口异步 + debounce、且幂等，重复回报不会造成多余重绘）。
    func startEarlyHingeTracking() {
        guard #available(iOS 27.1, macCatalyst 27.1, *) else { return }
        attachHingeInteractionToKeyWindow()
        guard hingeInteraction == nil else { return }
        // 启动当下可能还没有 key window：等 scene 激活后再挂一次。
        hingeTrackingObserver = NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.attachHingeInteractionToKeyWindow()
            }
        }
    }

    @available(iOS 27.1, macCatalyst 27.1, *)
    private func attachHingeInteractionToKeyWindow() {
        guard hingeInteraction == nil else { return }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first
        else { return }
        let interaction = UIHingeInteraction { [weak self] _, update in
            guard let self else { return }
            let newStatus = HingeStatus(hinge: update.hinge)
            let newAngleInDegrees = update.hinge.map { Double($0.angle) * 180 / .pi }
            Task { @MainActor in
                self.reportHingeObservation(status: newStatus, angleInDegrees: newAngleInDegrees)
            }
        }
        window.addInteraction(interaction)
        hingeInteraction = interaction
        let windowSizeRAW = String(describing: window.bounds.size)
        PZLog.info("已在启动阶段挂上铰链观察器（key window: \(windowSizeRAW)）")
    }
}
#endif

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension ScreenVM {
    /// 解析「本页清单列可用的内容宽」，供所有 `StaggeredGrid` 消费端使用。
    ///
    /// 依序采用：
    /// 1. `injected`：`\.listRowContentWidth` 环境值，即本页由 `reportListRowContentWidth()` 量到、
    ///    并经 `ScreenVM` 提交回来的同一世代实测值；
    /// 2. `mainColumnRowContentWidth`：主栏已提交的实测值；
    /// 3. 由主栏画布扣掉 `canvasInset` 的保守推算值（只有首帧才会用到）。
    ///
    /// 之所以需要 (2)：`\.listRowColumn` 的默认值恰好就是 `.mainColumn`，所以「本页回报到 main」
    /// 并不能证明本页确实落在该栏的环境子树内。实测（iPhone Duo，2026-10-08）`\.listRowContentWidth`
    /// 在 `SpecimenView` 与 `CharInventoryView` 上恒为 nil，消费端于是长期只能用 (3) 的固定内缩推算；
    /// 而该固定内缩在铰链半开 / 全开之间并不守恒——实测真实行宽 485 / 309，推算值却只有 436 / 384，
    /// `CharInventoryView.lineCapacity` 因此两边都算出 5，看起来就像「容量不随铰链状态更新」。
    public func resolvedListRowContentWidth(injected: CGFloat?, canvasInset: CGFloat) -> CGFloat {
        if let injected, injected > 0 { return injected }
        if mainColumnRowContentWidth > 0 { return mainColumnRowContentWidth }
        return Swift.max(mainColumnCanvasSizeObserved.width - canvasInset, 0)
    }
}
