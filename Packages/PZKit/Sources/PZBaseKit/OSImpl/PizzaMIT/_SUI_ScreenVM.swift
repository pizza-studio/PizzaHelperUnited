// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

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
                self.updateHash4Tracking()
            }
        }
        #else
        self.orientation = .landscape
        self.splitViewVisibility = .all // macOS 默认显示侧边栏
        #endif
        updateHash4Tracking() // 初始化 hashForTracking
        withObservationTracking {
            // _ = orientation <- 无须重複观测 orientation。
            _ = isHorizontallyCompact
            _ = actualSidebarWidthObserved
            _ = windowSizeObserved.hashValue
        } onChange: {
            Task { @MainActor in
                self.updateHash4Tracking()
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

    public var isSidebarVisible: Bool {
        var isSidebarVisibleNow = splitViewVisibility == .all
        isSidebarVisibleNow = isSidebarVisibleNow && !isHorizontallyCompact
        return isSidebarVisibleNow
    }

    // MARK: Private

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

    private func updateHash4Tracking() {
        var hasher = Hasher()
        hasher.combine(orientation)
        hasher.combine(isHorizontallyCompact)
        hasher.combine(actualSidebarWidthObserved)
        hasher.combine(windowSizeObserved.width)
        hasher.combine(windowSizeObserved.height)
        hashForTracking = hasher.finalize()
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
}

// MARK: ScreenVM.ViewTracker

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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
                .trackCanvasSize { newSizeRAW in
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
                    await pushTrackedPropertiesToScreenVM() // 立即执行
                }
                .react(to: combinedHash, initial: true) { _, _ in
                    Task {
                        await debouncer.debounce {
                            await pushTrackedPropertiesToScreenVM()
                        }
                    }
                }
        }

        // MARK: Private

        @State private var screenVM: ScreenVM = .shared
        @State private var debouncer: Debouncer
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

        private func pushTrackedPropertiesToScreenVM() async {
            defer {
                syncLayoutParamsToBackend()
            }
            // 似乎在 iOS 系统下没有办法停用与边栏有关的出入动画。
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
