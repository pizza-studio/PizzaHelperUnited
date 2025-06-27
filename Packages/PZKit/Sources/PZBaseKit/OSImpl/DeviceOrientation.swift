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

// MARK: - DeviceOrientation

@Observable
@MainActor
public final class DeviceOrientation: ObservableObject {
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

    public static let shared = DeviceOrientation()

    public var orientation: Orientation
    public var isHorizontallyCompact: Bool = OS.type == .iPhoneOS
    public var isSidebarVisible: Bool = OS.type != .iPhoneOS
    public var windowSizeObserved: CGSize = DeviceOrientation.getKeyWindowSize()

    // MARK: Private

    @ObservationIgnored private var listener: AnyCancellable?
}

extension DeviceOrientation {
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
