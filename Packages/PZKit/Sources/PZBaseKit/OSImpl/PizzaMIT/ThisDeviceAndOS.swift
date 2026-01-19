// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

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

// MARK: - ThisDevice

public enum ThisDevice {}

// MARK: - DeviceIDCache

/// 用於緩存 identifier4Vendor 的線程安全容器。
private final class DeviceIDCache: @unchecked Sendable {
    // MARK: Internal

    static let shared = DeviceIDCache()

    var value: String {
        lock.lock()
        defer { lock.unlock() }

        if let cached = _cachedValue {
            return cached
        }

        let computed = Self.computeIdentifier()
        _cachedValue = computed
        return computed
    }

    // MARK: Private

    private var _cachedValue: String?
    private let lock = NSLock()

    private static func computeIdentifier() -> String {
        #if os(watchOS)
        return UUID().uuidString
        #elseif canImport(IOKit) && canImport(UIKit)
        return getUIDeviceIdentifier() ?? ThisDevice.getIdentifier4Vendor() ?? UUID().uuidString
        #elseif canImport(UIKit) && !canImport(IOKit)
        return getUIDeviceIdentifier() ?? UUID().uuidString
        #elseif canImport(IOKit)
        return ThisDevice.getIdentifier4Vendor() ?? UUID().uuidString
        #else
        return UUID().uuidString
        #endif
    }

    #if canImport(UIKit) && !os(watchOS)
    private static func getUIDeviceIdentifier() -> String? {
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                UIDevice.current.identifierForVendor?.uuidString
            }
        }
        return DispatchQueue.main.sync {
            UIDevice.current.identifierForVendor?.uuidString
        }
    }
    #endif
}

#if os(watchOS)
extension ThisDevice {
    public static var identifier4Vendor: String { DeviceIDCache.shared.value }

    public static func getDeviceID4Vendor(_: String? = nil) -> String {
        identifier4Vendor
    }
}
#else
extension ThisDevice {
    public static var identifier4Vendor: String { DeviceIDCache.shared.value }

    public static func getDeviceID4Vendor(_ overridedValue: String? = nil) -> String {
        guard let overridedValue else { return identifier4Vendor }
        return overridedValue
    }
}
#endif

extension ThisDevice {
    // MARK: Public

    public static let modelIdentifier: String = getModelIdentifier()

    /// 獨立的 nonisolated 函數，用於取得裝置型號識別碼。
    /// 此函數不依賴任何 MainActor 隔離的 API，可安全地從任意執行緒呼叫。
    public nonisolated static func getModelIdentifier() -> String {
        #if os(macOS)
        let service: io_service_t = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
        if let model = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0) {
            if let modelStr = model.takeRetainedValue() as? String {
                IOObjectRelease(service)
                return modelStr
            }
        }
        IOObjectRelease(service)
        return "UnknownMac"
        #elseif os(iOS) || targetEnvironment(macCatalyst)
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
        #elseif os(watchOS)
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
    }

    // MARK: Fileprivate

    #if canImport(IOKit)
    fileprivate nonisolated static func getIdentifier4Vendor() -> String? {
        // Returns an object with a +1 retain count; the caller needs to release.
        func ioService(named name: String, wantBuiltIn: Bool) -> io_service_t? {
            let default_port: mach_port_t
            if #unavailable(macCatalyst 15.0, iOS 15.0) {
                default_port = kIOMasterPortDefault
            } else {
                default_port = kIOMainPortDefault
            }
            var iterator = io_iterator_t()
            defer { if iterator != IO_OBJECT_NULL { IOObjectRelease(iterator) } }

            guard let matchingDict = IOBSDNameMatching(default_port, 0, name) else { return nil }
            let matchingStatus = IOServiceGetMatchingServices(
                default_port,
                matchingDict as CFDictionary,
                &iterator
            )
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

// MARK: - OS

public enum OS: Int, Sendable {
    case macOS = 0
    case iPhoneOS = 1
    case iPadOS = 2
    case watchOS = 3
    case tvOS = 4

    // MARK: Public

    public static let isAppKit: Bool = {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }()

    /// iOS 18.0 ~ 18.3 有关于画面底部的 Bottom Toolbar 的故障，需要单独应对。
    public static let isBuggyOS25Build: Bool = {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        guard #unavailable(iOS 18.4) else { return false }
        guard #available(iOS 18.0, *)
        else { return false }
        return true
        #else
        return false
        #endif
    }()

    public static let liquidGlassThemeSuspected: Bool = {
        if let infoDict = Bundle.main.infoDictionary {
            let verStr = (infoDict["DTPlatformVersion"] as? String)?.prefix(4) ?? "_"
            if let verDouble = Double(verStr) {
                if verDouble < 26 { return false }
                let uiCompat = infoDict["UIDesignRequiresCompatibility"] as? Bool
                if uiCompat == true { return false }
            }
        }
        #if os(macOS)
        return if #unavailable(macOS 26) { false } else { true }
        #elseif os(watchOS)
        return if #unavailable(watchOS 26) { false } else { true }
        #elseif os(tvOS)
        return if #unavailable(tvOS 26) { false } else { true }
        #elseif os(iOS)
        #if targetEnvironment(simulator)
        return if #unavailable(iOS 26) { false } else { true }
        #elseif targetEnvironment(macCatalyst)
        return if #unavailable(macCatalyst 26) { false } else { true }
        #else
        return if #unavailable(iOS 26) { false } else { true }
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

    /// 當前作業系統類型。此值在首次存取時會自動初始化（需從 MainActor 上下文首次呼叫）。
    /// 初始化後可從任何執行緒安全存取。
    public static var type: OS { OSTypeCache.shared.value }

    public static var isOS25OrNewer: Bool {
        switch OS.type {
        case .macOS:
            if #available(macOS 15, *) { return true }
            if #available(macCatalyst 18, *) { return true }
            return false
        case .iPhoneOS:
            if #available(iOS 18, *) { return true }
            return false
        case .iPadOS:
            if #available(iOS 18, *) { return true }
        case .watchOS:
            if #available(watchOS 11, *) { return true }
        case .tvOS:
            if #available(tvOS 18, *) { return true }
        }
        return false
    }

    public static func initializeOSType() {
        _ = OS.type
    }
}

// MARK: - OSTypeCache

/// 用於緩存 OS.type 的線程安全容器。
/// 使用 `nonisolated(unsafe)` 配合內部同步機制，確保初始化後可從任意執行緒安全存取。
private final class OSTypeCache: @unchecked Sendable {
    // MARK: Internal

    static let shared = OSTypeCache()

    var value: OS {
        lock.lock()
        defer { lock.unlock() }

        if let cached = _cachedValue {
            return cached
        }

        let computed = Self.computeOSType()
        _cachedValue = computed
        return computed
    }

    // MARK: Private

    private static var maybePad: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        // 優先使用 modelIdentifier 判斷（nonisolated 函數，不需要 MainActor）
        if ThisDevice.getModelIdentifier().contains("iPad") { return true }
        // 使用 DispatchQueue.main.sync 安全地從 MainActor 取值
        // 注意：如果已經在 main thread 上，使用 MainActor.assumeIsolated
        if Thread.isMainThread {
            return MainActor.assumeIsolated {
                UIDevice.current.userInterfaceIdiom == .pad
            }
        }
        return DispatchQueue.main.sync {
            UIDevice.current.userInterfaceIdiom == .pad
        }
        #else
        return false
        #endif
    }

    private var _cachedValue: OS?
    private let lock = NSLock()

    private static func computeOSType() -> OS {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return .macOS }
        #if DEBUG
        if ProcessInfo.processInfo.environment["SIMULATE_MAC_ENV"] == "YES" { return .macOS }
        #endif
        #if os(macOS)
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
    }
}

// MARK: - Window Size Helpers

#if os(macOS) || os(iOS) || targetEnvironment(macCatalyst)
@available(iOS 15.0, macCatalyst 15.0, *)
@MainActor
extension ThisDevice {
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
#endif

#if canImport(UIKit)
extension UIEdgeInsets {
    fileprivate var allParamters: [CGFloat] {
        [bottom, top, left, right]
    }
}
#endif
