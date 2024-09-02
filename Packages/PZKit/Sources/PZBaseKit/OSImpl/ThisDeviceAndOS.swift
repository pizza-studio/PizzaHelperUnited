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
