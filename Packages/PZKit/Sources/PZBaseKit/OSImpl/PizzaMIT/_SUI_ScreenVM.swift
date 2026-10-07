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
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms 去抖动
                try? Task.checkCancellation()
                self.orientation = newOrientation
                PZLog.info(
                    "方向更新: \(newOrientation.rawValue), windowSizeObserved: \(String(describing: self.windowSizeObserved))"
                )
                self.updateHash4Tracking()
            }
        }
        #else
        self.orientation = .landscape
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

    public static let shared = ScreenVM()

    public var orientation: Orientation
    public var hingeStatus: HingeStatus?
    /// 折叠装置铰链的开阖角度（度数）。`nil` 的含义与 `hingeStatus` 相同。
    /// 铰链掀动时此值会高频更新；需要订阅的视图直接读它即可（`ScreenVM` 是 @Observable）。
    public var hingeAngleInDegrees: Double?
    public var isHorizontallyCompact: Bool = OS.type == .iPhoneOS
    public var actualSidebarWidthObserved: CGFloat = 0
    public var windowSizeObserved: CGSize = ScreenVM.getKeyWindowSize()
    public var splitViewVisibility: NavigationSplitViewVisibility

    /// Sidebar padding 偏移量。经由 CanvasSizeTracker 直接量取校准。
    /// 初始值为 0（假设无 padding）；由 ContentView 中的 tracker 实际量取后修正。
    /// 该值恒为非负数。
    public var mainColumnSidebarPaddingOffset: CGFloat = 0

    public private(set) var hashForTracking: Int = 0

    /// Main Column 的画布尺寸。
    /// 从 `windowSizeObserved` — `actualSidebarWidthObserved` — `mainColumnSidebarPaddingOffset` 推算。
    /// 由于读取了三个 @Observable stored property，它们任一变化都会触发依赖方重绘。
    public var mainColumnCanvasSizeObserved: CGSize {
        var newResult = windowSizeObserved
        guard splitViewVisibility != .detailOnly else { return newResult }
        newResult.width -= actualSidebarWidthObserved
        newResult.width -= mainColumnSidebarPaddingOffset
        guard newResult.width > 0 else { return windowSizeObserved }
        return newResult
    }

    // iPhone Portrait Display mode or similar canvas size.
    // 440 是 iPhone 16 Pro Max 的荧幕画布尺寸。
    public var isPhonePortraitSituation: Bool {
        isHorizontallyCompact && windowSizeObserved.width <= 440
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
        guard hingeStatus != nil else { return false }
        return (hingeAngleInDegrees ?? 0) > 0
    }

    /// App 的视窗是否占满整个萤幕，而不是被系统塞在左页、右页或上下其中一页。
    ///
    /// 实测 iPhone Duo 满版时视窗约为萤幕的 0.88～0.95（差额来自状态栏与边缘安全区）；
    /// 被塞进单页时其中一轴只剩约 0.5，故门槛取 0.75。
    public var isAppOccupyingWholeScreen: Bool {
        Self.isAppOccupyingWholeScreen(windowSize: windowSizeObserved, screenSize: Self.getScreenSize())
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

    /// 回报一次铰链观测结果。
    ///
    /// **异步 + debounce**：铰链在扳动时会高频回报，这里等它静下来之后才真正写入 `ScreenVM`
    /// （trailing-edge：后一次回报会取消前一次待处理的写入）。
    public func reportHingeObservation(status: HingeStatus?, angleInDegrees: Double?) async {
        await hingeObservationDebouncer.debounce { [weak self] in
            await self?.applyHingeObservation(status: status, angleInDegrees: angleInDegrees)
        }
    }

    public func handleTrackedMainColumnCanvasSize(_ trackedSize: CGSize) {
        let measuredWidth = trackedSize.width.rounded(.up)
        let sidebarWidth = actualSidebarWidthObserved.rounded(.up)
        let windowWidth = windowSizeObserved.width.rounded(.up)
        let computedWidth = windowWidth - sidebarWidth
        guard computedWidth > 0 else { return }
        let offset = (computedWidth - measuredWidth).rounded(.up)
        let clampedOffset = max(0, offset)
        if mainColumnSidebarPaddingOffset != clampedOffset {
            mainColumnSidebarPaddingOffset = clampedOffset
        }
    }

    public func handleTrackedSidebarCanvasSize(_ trackedSize: CGSize) {
        let existingWidth = actualSidebarWidthObserved
        let newValue = trackedSize.width.rounded(.up)
        guard existingWidth != newValue else { return }
        actualSidebarWidthObserved = newValue
    }

    // MARK: Private

    /// 铰链观测的写入去抖器（与画布尺寸观测推導使用同一套 `Debouncer` 机制）。
    private let hingeObservationDebouncer: Debouncer = .init(delay: 0.1)

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// 启动阶段就挂在 key window 上的铰链观察器；见 `startEarlyHingeTracking()`。
    @ObservationIgnored private var hingeInteraction: (any UIInteraction)?
    @ObservationIgnored private var hingeTrackingObserver: (any NSObjectProtocol)?
    #endif

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

    /// 真正把铰链观测结果写入 `ScreenVM`。
    private func applyHingeObservation(status newStatus: HingeStatus?, angleInDegrees newAngleInDegrees: Double?) {
        guard hingeStatus != newStatus || hingeAngleInDegrees != newAngleInDegrees else { return }
        let previousIsOpen = isHingeOpen
        let statusDidChange = hingeStatus != newStatus
        hingeStatus = newStatus
        hingeAngleInDegrees = newAngleInDegrees
        let openStateDidChange = previousIsOpen != isHingeOpen
        // 记下来给下次启动当暂定值用（含主动清空的情形）。
        Defaults[.lastKnownHingeStatus] = newStatus?.rawValue
        Defaults[.lastKnownHingeAngleInDegrees] = newAngleInDegrees
        // 角度会在高频扳动时变化，因此只在开阖状态改变时才写日志与更新追踪哈希。
        guard statusDidChange || openStateDidChange else { return }
        updateHash4Tracking()
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
        hashForTracking = hasher.finalize()
    }

    private func registerObservation() {
        withObservationTracking {
            // _ = orientation <- 无须重複观测 orientation。
            _ = hingeStatus
            _ = isHorizontallyCompact
            _ = actualSidebarWidthObserved
            _ = windowSizeObserved.hashValue
            _ = mainColumnSidebarPaddingOffset
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let this = self else { return }
                this.updateHash4Tracking()
                this.registerObservation()
            }
        }
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

// MARK: ScreenVM.ViewTracker

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension ScreenVM {
    fileprivate struct ViewTracker: ViewModifier {
        // MARK: Lifecycle

        public init(debounceDelay: TimeInterval = 0.1) {
            self.debounceDelay = debounceDelay
            self._debouncer = .init(wrappedValue: Debouncer(delay: debounceDelay))
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
                .trackCanvasSize(debounceDelay: debounceDelay) { newSizeRAW in
                    var newSize = newSizeRAW
                    newSize.width.round(.up)
                    newSize.height.round(.up)
                    let oldSize = screenVM.windowSizeObserved
                    if oldSize.width != newSize.width {
                        screenVM.windowSizeObserved.width = newSize.width
                    }
                    if oldSize.height != newSize.height {
                        screenVM.windowSizeObserved.height = newSize.height
                    }
                }
                .onAppBecomeActive {
                    Task {
                        await debouncer.debounce {
                            await pushTrackedPropertiesToScreenVM()
                        }
                    }
                }
                .task {
                    // 立即重讀 window size：macOS / macCatalyst 初始化時 keyWindow 可能尚未就緒，
                    // 導致 windowSizeObserved 降級為 iPhone SE 的 375×667。
                    screenVM.windowSizeObserved = ScreenVM.getKeyWindowSize()
                    await pushTrackedPropertiesToScreenVM() // 立即执行
                }
                .react(to: combinedHash, initial: true) { _, _ in
                    Task {
                        await debouncer.debounce {
                            await pushTrackedPropertiesToScreenVM()
                        }
                    }
                }
                .trackDeviceHinge()
        }

        // MARK: Private

        @State private var screenVM: ScreenVM = .shared
        @State private var debouncer: Debouncer
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

        private let debounceDelay: TimeInterval

        private func pushTrackedPropertiesToScreenVM() async {
            defer {
                syncLayoutParamsToBackend()
            }
            // 似乎在 iOS 系统下没有办法停用与边栏有关的出入动画。
            guard OS.type != .macOS else {
                applySplitViewVisibility(.all, reason: "macOS")
                return
            }
            // 边栏是否显示交给 `shouldShowSidebar` 单点判定（铰链张开时改看视窗长宽比）。
            let isCompactWidth = (horizontalSizeClass ?? .regular) == .compact
            let showsSidebar = screenVM.shouldShowSidebar(isCompactWidth: isCompactWidth)
            let windowSize = screenVM.windowSizeObserved
            let windowSizeRAW = "\(Int(windowSize.width))×\(Int(windowSize.height))"
            let hingeNote = windowSize.width > windowSize.height ? "比高宽" : "比宽高"
            let reason: String = screenVM.isHingeOpen
                ? "铰链张开：占满萤幕 \(screenVM.isAppOccupyingWholeScreen)，视窗 \(windowSizeRAW)（\(hingeNote)）"
                : "铰链未张开：\(screenVM.orientation.rawValue)，compact 宽度 \(isCompactWidth)"
            applySplitViewVisibility(showsSidebar ? .all : .detailOnly, reason: reason)
        }

        private func applySplitViewVisibility(
            _ newValue: NavigationSplitViewVisibility,
            reason: String
        ) {
            guard screenVM.splitViewVisibility != newValue else { return }
            screenVM.splitViewVisibility = newValue
            PZLog.info("splitViewVisibility 更新为 \(String(describing: newValue))（\(reason)）")
        }

        private func syncLayoutParamsToBackend() {
            screenVM.isHorizontallyCompact = (horizontalSizeClass ?? .regular) == .compact
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension View {
    @ViewBuilder
    public func trackScreenVMParameters(debounceDelay: TimeInterval = 0.1) -> some View {
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
                await ScreenVM.shared.reportHingeObservation(status: newStatus, angleInDegrees: newAngleInDegrees)
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
                await self.reportHingeObservation(status: newStatus, angleInDegrees: newAngleInDegrees)
            }
        }
        window.addInteraction(interaction)
        hingeInteraction = interaction
        let windowSizeRAW = String(describing: window.bounds.size)
        PZLog.info("已在启动阶段挂上铰链观察器（key window: \(windowSizeRAW)）")
    }
}
#endif
