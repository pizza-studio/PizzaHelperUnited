// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(IOKit)
import IOKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif

#if os(macOS) || os(iOS) || targetEnvironment(macCatalyst)
public enum ThisDevice {
    // MARK: Public

    public static let modelIdentifier: String = {
        #if os(macOS) || targetEnvironment(macCatalyst)
        let service: io_service_t = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        let model = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0)
        return modelIdentifier as String
        #elseif os(iOS)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children
            .reduce("") { identifier, element in
                guard let value = element.value as? Int8,
                      value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        return identifier
        #endif
    }()

    public static let identifier4Vendor: String = {
        #if canImport(IOKit) && canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? getIdentifier4Vendor() ?? UUID().uuidString
        #elseif canImport(UIKit) && !canImport(IOKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #elseif canImport(IOKit)
        return getIdentifier4Vendor() ?? UUID().uuidString
        #else
        return UUID().uuidString
        #endif
    }()

    // MARK: Private

    #if canImport(IOKit)
    private static func getIdentifier4Vendor() -> String? {
        // Returns an object with a +1 retain count; the caller needs to release.
        func ioService(named name: String, wantBuiltIn: Bool) -> io_service_t? {
            let default_port = kIOMainPortDefault
            var iterator = io_iterator_t()
            defer { if iterator != IO_OBJECT_NULL { IOObjectRelease(iterator) } }

            guard let matchingDict = IOBSDNameMatching(default_port, 0, name) else { return nil }
            let matchingStatus = IOServiceGetMatchingServices(default_port, matchingDict as CFDictionary, &iterator)
            guard matchingStatus == KERN_SUCCESS, iterator != IO_OBJECT_NULL else { return nil }

            var candidate = IOIteratorNext(iterator)
            while candidate != IO_OBJECT_NULL {
                if let cftype = IORegistryEntryCreateCFProperty(
                    candidate,
                    "IOBuiltin" as CFString,
                    kCFAllocatorDefault,
                    0
                ) {
                    let isBuiltIn = cftype.takeRetainedValue() as! CFBoolean
                    if wantBuiltIn == CFBooleanGetValue(isBuiltIn) {
                        return candidate
                    }
                }

                IOObjectRelease(candidate)
                candidate = IOIteratorNext(iterator)
            }

            return nil
        }

        // Prefer built-in network interfaces.
        // For example, an external Ethernet adaptor can displace
        // the built-in Wi-Fi as en0.
        guard let service = ioService(named: "en0", wantBuiltIn: true)
            ?? ioService(named: "en1", wantBuiltIn: true)
            ?? ioService(named: "en0", wantBuiltIn: false)
        else { return nil }
        defer { IOObjectRelease(service) }

        let cftype = IORegistryEntrySearchCFProperty(
            service,
            kIOServicePlane,
            "IOMACAddress" as CFString,
            kCFAllocatorDefault,
            IOOptionBits(kIORegistryIterateRecursively | kIORegistryIterateParents)
        )

        guard let data = cftype as? Data else { return nil }
        let xArray = data.map { $0.description }.joined()
        return try? UUID.fromMD5(xArray.md5).uuidString
    }
    #endif
}
#endif

// MARK: - OS

public enum OS: Int {
    case macOS = 0
    case iPhoneOS = 1
    case iPadOS = 2
    case watchOS = 3
    case tvOS = 4

    // MARK: Public

    public static let type: OS = {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return .macOS }
        #if os(OSX)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(iOS)
        #if targetEnvironment(simulator)
        return maybePad ? .iPadOS : .iPhoneOS
        #elseif targetEnvironment(macCatalyst)
        return .macOS
        #else
        return maybePad ? .iPadOS : .iPhoneOS
        #endif
        #endif
    }()

    public static let isCatalyst: Bool = {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }()

    // MARK: Private

    private static let maybePad: Bool = {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return ThisDevice.modelIdentifier.contains("iPad") || UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }()
}

// MARK: - Window Size Helpers

extension ThisDevice {
    public static var basicWindowSize: CGSize {
        DeviceOrientation.basicWindowSize
    }

    public static var isScreenLandScape: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 > 0 }
        return filtered.count == 3
        #else
        return true
        #endif
    }

    public static var isHDScreenRatio: Bool {
        #if canImport(UIKit)
        let screenSize = UIScreen.main.bounds.size
        let big = max(screenSize.width, screenSize.height)
        let small = min(screenSize.width, screenSize.height)
        return (1.76 ... 1.78).contains(big / small)
        #else
        return false
        #endif
    }

    public static var isHDPhoneOrPodTouch: Bool {
        isHDScreenRatio && OS.type == .iPhoneOS
    }

    public static var isSmallestSlideOverWindowWidth: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return Self.isSmallestHDScreenPhone }
        return min(window.frame.width, window.frame.height) < 375
        #else
        return false
        #endif
    }

    /// 检测荧幕解析度是否为 iPhone 5 / 5c / 5s / SE Gen1 / iPod Touch 7th Gen 的最大荧幕解析度。
    /// 如果是 iPhone SE2 / SE3 / 6 / 7 / 8 且开启了荧幕放大模式的话，也会用到这个解析度。
    /// 不考虑 4:3 荧幕的机种（iPhone 4s 为止的机种）。
    public static var isSmallestHDScreenPhone: Bool {
        #if canImport(UIKit)
        // 仅列出至少有支援 iOS 14 的机种。
        guard !["iPhone8,4", "iPod9,1"].contains(ThisDevice.modelIdentifier)
        else {
            return true
        }
        let screenSize = UIScreen.main.bounds
        return min(screenSize.width, screenSize.height) < 375
        #else
        return false
        #endif
    }

    public static var scaleRatioCompatible: CGFloat {
        DeviceOrientation.scaleRatioCompatible
    }

    public static var isThinnestSplitOnPad: Bool {
        #if canImport(UIKit)
        guard OS.type == .iPadOS, isSplitOrSlideOver else { return false }
        guard let window = getKeyWindow() else { return false }
        let windowSize = window.frame.size
        let big = max(windowSize.width, windowSize.height)
        let small = min(windowSize.width, windowSize.height)
        return (2.2 ... 4).contains(big / small)
        #else
        return false
        #endif
    }

    public static var isWidestSplitOnPad: Bool {
        #if canImport(UIKit)
        guard OS.type == .iPadOS, isSplitOrSlideOver else { return false }
        guard let window = getKeyWindow() else { return false }
        let windowSize = window.frame.size
        let big = max(windowSize.width, windowSize.height)
        let small = min(windowSize.width, windowSize.height)
        return (1 ... 1.05).contains(big / small)
        #else
        return false
        #endif
    }

    public static var isSplitOrSlideOver: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return false }
        return window.frame.width != window.screen.bounds.width
        #else
        return false
        #endif
    }

    public static var isRunningInFullScreen: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return true }
        let screenSize = UIScreen.main.bounds.size
        let appSize = window.bounds.size
        let compatibleA = CGRectEqualToRect(
            CGRect(origin: .zero, size: screenSize),
            CGRect(origin: .zero, size: appSize)
        )
        let appSizeFlipped = CGSize(
            width: appSize.height,
            height: appSize.width
        )
        let compatibleB = CGRectEqualToRect(
            CGRect(origin: .zero, size: screenSize),
            CGRect(origin: .zero, size: appSizeFlipped)
        )
        return compatibleA || compatibleB
        #else
        return false
        #endif
    }

    #if canImport(UIKit)
    public static func getKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }
            .first
    }
    #endif

    // MARK: Internal

    enum NotchType {
        case normalNotch
        case dynamicIsland
        case none
    }

    static var notchType: NotchType {
        guard hasNotchOrDynamicIsland else { return .none }
        guard hasDynamicIsland else { return .normalNotch }
        return .dynamicIsland
    }

    // MARK: Private

    private static var hasDynamicIsland: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 59 }
        return filtered.count == 1
        #else
        return false
        #endif
    }

    private static var hasNotchOrDynamicIsland: Bool {
        #if canImport(UIKit)
        guard let window = getKeyWindow() else { return false }
        let filtered = window.safeAreaInsets.allParamters.filter { $0 >= 44 }
        return filtered.count == 1
        #else
        return false
        #endif
    }
}

#if canImport(UIKit)
extension UIEdgeInsets {
    fileprivate var allParamters: [CGFloat] {
        [bottom, top, left, right]
    }
}
#endif
