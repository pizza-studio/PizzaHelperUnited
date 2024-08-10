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
