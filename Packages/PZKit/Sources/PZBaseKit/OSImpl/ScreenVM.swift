// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

#if !os(watchOS)
#if canImport(AppKit)
import AppKit
#endif
@preconcurrency import Combine
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

// MARK: - ScreenVM

@Observable
@MainActor
public final class ScreenVM: ObservableObject {
    // MARK: Lifecycle

    public init() {
        #if canImport(UIKit)
        self.orientation = UIDevice.current.orientation
            .isLandscape ? .landscape : .portrait
        self.listener = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .compactMap { deviceOrientation -> Orientation? in
                if deviceOrientation.isPortrait {
                    return .portrait
                } else if deviceOrientation.isLandscape {
                    return .landscape
                } else {
                    return nil
                }
            }
            .assign(to: \.orientation, on: self)
        #else
        self.orientation = .landscape
        #endif
    }

    deinit {
        listener?.cancel()
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
    public var windowSizeObserved: CGSize = ScreenVM.getKeyWindowSize()
    public var splitViewVisibility: NavigationSplitViewVisibility = .all

    public var hashForTracking: Int {
        var hasher = Hasher()
        // 此处无须追踪 splitViewVisibility，因为 splitViewVisibility 不是用户能单独开关控制的。
        hasher.combine(orientation)
        hasher.combine(orientation)
        hasher.combine(windowSizeObserved.width)
        hasher.combine(windowSizeObserved.height)
        return hasher.finalize()
    }

    // MARK: Private

    @ObservationIgnored private var listener: AnyCancellable?
}

extension ScreenVM {
    public static var basicWindowPixelSize: CGSize {
        .init(
            width: 622,
            height: 1107
        )
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
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }
            .first?.frame.size ?? .init(width: 375, height: 667)
        #elseif canImport(AppKit)
        return NSApplication.shared.keyWindow?.frame.size ?? .init(width: 375, height: 667)
        #endif
    }
}
#endif

// MARK: - ScreenVM.ViewTracker

extension ScreenVM {
    fileprivate struct ViewTracker: ViewModifier {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public func body(content: Content) -> some View {
            content
                .background {
                    Color.clear
                        .containerRelativeFrame(Axis.Set([.horizontal, .vertical])) { value, axis in
                            Task { @MainActor in
                                switch axis {
                                case .horizontal: screenVM.windowSizeObserved.width = value
                                case .vertical: screenVM.windowSizeObserved.height = value
                                }
                            }
                            return value
                        }
                }
                .onAppBecomeActive {
                    pushTrackedPropertiesToScreenVM()
                }
                .task {
                    pushTrackedPropertiesToScreenVM()
                }
                .onChange(of: screenVM.hashForTracking, initial: true) { _, _ in
                    pushTrackedPropertiesToScreenVM()
                }
        }

        // MARK: Private

        @StateObject private var screenVM = ScreenVM.shared
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

        private var isSidebarVisible: Bool {
            screenVM.splitViewVisibility == .all && !isCompact
        }

        private var isCompact: Bool {
            horizontalSizeClass == .compact
        }

        private func pushTrackedPropertiesToScreenVM() {
            defer {
                syncLayoutParamsToBackend()
            }
            guard OS.type != .macOS else {
                screenVM.splitViewVisibility = .all
                return
            }
            switch screenVM.orientation {
            case .landscape where !isCompact: screenVM.splitViewVisibility = .all
            default: screenVM.splitViewVisibility = .detailOnly
            }
        }

        private func syncLayoutParamsToBackend() {
            screenVM.isHorizontallyCompact = isCompact
            screenVM.isSidebarVisible = isSidebarVisible
        }
    }
}

extension View {
    @ViewBuilder
    public func trackScreenVMParameters() -> some View {
        modifier(ScreenVM.ViewTracker())
    }
}
