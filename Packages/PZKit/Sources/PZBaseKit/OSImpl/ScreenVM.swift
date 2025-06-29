// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

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

@Observable
@MainActor
public final class ScreenVM: ObservableObject {
    // MARK: Lifecycle

    public init() {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        // 启用设备方向通知
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        // 使用 UIWindowScene.interfaceOrientation 作为回退
        let orientationNow = Self.getInitialOrientation()
        self.orientation = orientationNow
        // 初始化 splitViewVisibility
        self.splitViewVisibility = Self.initialSplitViewVisibility(
            orientation: orientationNow,
            horizontalSizeClass: Self.getInitialHorizontalSizeClass()
        )
        print("初始方向: \(orientation), splitViewVisibility: \(splitViewVisibility)")
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
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms 去抖动
                try Task.checkCancellation()
                self.orientation = newOrientation
                print("方向更新: \(newOrientation), windowSizeObserved: \(windowSizeObserved)")
                self.updateHash4TrackingWithDebounce()
            }
        }
        #else
        self.orientation = .landscape
        self.splitViewVisibility = .all // macOS 默认显示侧边栏
        #endif
        updateHash4Tracking() // 初始化 hashForTracking
        withObservationTracking {
            _ = orientation
            _ = isHorizontallyCompact
            _ = isSidebarVisible
            _ = actualSidebarWidthObserved
            _ = windowSizeObserved.width
            _ = windowSizeObserved.height
        } onChange: {
            Task { @MainActor in
                self.updateHash4TrackingWithDebounce()
            }
        }
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

    public static let shared = ScreenVM()

    public var orientation: Orientation
    public var isHorizontallyCompact: Bool = OS.type == .iPhoneOS
    public var isSidebarVisible: Bool = OS.type != .iPhoneOS
    public var actualSidebarWidthObserved: CGFloat = 0
    public var windowSizeObserved: CGSize = ScreenVM.getKeyWindowSize()
    public var splitViewVisibility: NavigationSplitViewVisibility

    public private(set) var hashForTracking: Int = 0

    public var mainColumnCanvasSizeObserved: CGSize {
        var newResult = windowSizeObserved
        guard splitViewVisibility != .detailOnly else { return newResult }
        newResult.width -= actualSidebarWidthObserved
        guard newResult.width > 0 else { return windowSizeObserved }
        return newResult
    }

    public var isExtremeCompact: Bool {
        mainColumnCanvasSizeObserved.width < 375 // iPhone SE3 ZOOMED mode.
    }

    // MARK: Private

    @ObservationIgnored private let debouncer: Debouncer = .init(delay: 0.1)

    // MARK: Static Helpers

    private static func getInitialOrientation() -> Orientation {
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

    private static func initialSplitViewVisibility(
        orientation: Orientation,
        horizontalSizeClass: UserInterfaceSizeClass?
    )
        -> NavigationSplitViewVisibility {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if orientation == .landscape, horizontalSizeClass != .compact {
            return .all
        }
        return .detailOnly
        #else
        return .all // macOS 默认显示侧边栏
        #endif
    }

    private func updateHash4TrackingWithDebounce() {
        debouncer.debounce {
            self.updateHash4Tracking()
        }
    }

    private func updateHash4Tracking() {
        var hasher = Hasher()
        hasher.combine(orientation)
        hasher.combine(isHorizontallyCompact)
        hasher.combine(isSidebarVisible)
        hasher.combine(actualSidebarWidthObserved)
        hasher.combine(windowSizeObserved.width)
        hasher.combine(windowSizeObserved.height)
        hashForTracking = hasher.finalize()
    }
}

// MARK: - UIWindowScene Orientation Extension

#if os(iOS) && !targetEnvironment(macCatalyst)
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

extension ScreenVM {
    public static var basicWindowPixelSize: CGSize {
        .init(width: 622, height: 1107)
    }

    public static func calculateScaleRatio(canvasSize: CGSize) -> CGFloat {
        var result = canvasSize.width / basicWindowPixelSize.width
        let zoomedSize = CGSize(
            width: basicWindowPixelSize.width * result,
            height: basicWindowPixelSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: canvasSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = canvasSize.height / basicWindowPixelSize.height
        }
        return result
    }

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
}

// MARK: ScreenVM.ViewTracker

extension ScreenVM {
    fileprivate struct ViewTracker: ViewModifier {
        // MARK: Lifecycle

        public init(debounceDelay: TimeInterval = 0.1) {
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
                .trackCanvasSize { newSize in
                    screenVM.windowSizeObserved = newSize
                }
                .onAppBecomeActive {
                    debouncer.debounce {
                        await pushTrackedPropertiesToScreenVM()
                    }
                }
                .task {
                    await pushTrackedPropertiesToScreenVM() // 立即执行
                }
                .onChange(of: combinedHash, initial: true) { _, _ in
                    debouncer.debounce {
                        await pushTrackedPropertiesToScreenVM()
                    }
                }
        }

        // MARK: Private

        @StateObject private var screenVM = ScreenVM.shared
        @StateObject private var debouncer: Debouncer
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

        private func pushTrackedPropertiesToScreenVM() async {
            defer {
                syncLayoutParamsToBackend()
            }
            guard OS.type != .macOS else {
                screenVM.splitViewVisibility = .all
                return
            }
            switch screenVM.orientation {
            case .landscape where horizontalSizeClass ?? .regular != .compact:
                screenVM.splitViewVisibility = .all
            default:
                screenVM.splitViewVisibility = .detailOnly
            }
        }

        private func syncLayoutParamsToBackend() {
            screenVM.isHorizontallyCompact = (horizontalSizeClass ?? .regular) == .compact
            var isSidebarVisibleNow = screenVM.splitViewVisibility == .all
            isSidebarVisibleNow = isSidebarVisibleNow && (horizontalSizeClass ?? .regular) != .compact
            screenVM.isSidebarVisible = isSidebarVisibleNow
        }
    }
}

// MARK: - Debouncer

@MainActor
private class Debouncer: ObservableObject {
    // MARK: Lifecycle

    init(delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: Internal

    func debounce(_ action: @escaping @MainActor () async -> Void) {
        task?.cancel()
        task = Task { @MainActor in
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            try Task.checkCancellation()
            await action()
        }
    }

    // MARK: Private

    private var task: Task<Void, Error>?
    private let delay: TimeInterval
}

extension View {
    @ViewBuilder
    public func trackScreenVMParameters(debounceDelay: TimeInterval = 0.1) -> some View {
        modifier(ScreenVM.ViewTracker(debounceDelay: debounceDelay))
    }
}
