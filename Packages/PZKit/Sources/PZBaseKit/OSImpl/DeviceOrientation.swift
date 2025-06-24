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

    public enum Orientation {
        case portrait
        case landscape
    }

    // MARK: Internal

    var orientation: Orientation

    // MARK: Private

    @ObservationIgnored private var listener: AnyCancellable?
}

extension DeviceOrientation {
    public static var basicWindowSize: CGSize {
        .init(
            width: 622,
            height: 1107
        )
    }

    public static var scaleRatioCompatible: CGFloat {
        guard let windowSize = getKeyWindowSize() else { return 1 }
        // 对哀凤优先使用宽度适配，没准哪天哀凤长得跟法棍面包似的也说不定。
        var result = windowSize.width / basicWindowSize.width
        let zoomedSize = CGSize(
            width: basicWindowSize.width * result,
            height: basicWindowSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: windowSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = windowSize.height / basicWindowSize.height
        }
        return result
    }

    public static func calculateScaleRatio(canvasSize: CGSize) -> CGFloat {
        var result = canvasSize.width / basicWindowSize.width
        let zoomedSize = CGSize(
            width: basicWindowSize.width * result,
            height: basicWindowSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: canvasSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = canvasSize.height / basicWindowSize.height
        }
        return result
    }

    public static func getKeyWindowSize() -> CGSize? {
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }
            .first?.frame.size
        #elseif canImport(AppKit)
        return NSApplication.shared.keyWindow?.frame.size
        #endif
    }
}
#endif
